#!/usr/bin/env bash

#
# Apache Maven Installation Script
#
# Target OS:
#   Ubuntu 22.04 / 24.04
#
# Package Manager Notes:
#   Ubuntu/Debian  -> apt
#   Amazon Linux   -> dnf
#   RHEL/CentOS    -> yum or dnf
#
# Maven Installation Location:
#   /opt/maven
#
# This script is idempotent and may be executed
# multiple times safely.
#

set -euo pipefail

MAVEN_VERSION="3.9.12"
MAVEN_ARCHIVE="apache-maven-${MAVEN_VERSION}-bin.tar.gz"
MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/${MAVEN_ARCHIVE}"
INSTALL_DIR="/opt/maven"

echo "========== Apache Maven Installation =========="

# Configure hostname only if required
CURRENT_HOSTNAME=$(hostname)

if [ "$CURRENT_HOSTNAME" != "mavenbuild" ]; then
    echo "Setting hostname to mavenbuild..."
    sudo hostnamectl set-hostname mavenbuild
else
    echo "Hostname already configured."
fi

# Refresh package repositories
echo "Updating package repositories..."
sudo apt update

# Install common administration and DevOps utilities
echo "Installing required utilities..."
sudo apt install -y wget nano tree unzip git

# Install Java 11 if not already installed
# Some enterprise Java applications still require Java 11
if ! dpkg -s openjdk-11-jdk >/dev/null 2>&1; then
    echo "Installing OpenJDK 11..."
    sudo apt install -y openjdk-11-jdk
else
    echo "OpenJDK 11 already installed."
fi

# Install Java 17 if not already installed
# Many modern Java applications target Java 17 LTS
if ! dpkg -s openjdk-17-jdk >/dev/null 2>&1; then
    echo "Installing OpenJDK 17..."
    sudo apt install -y openjdk-17-jdk
else
    echo "OpenJDK 17 already installed."
fi

# Verify Java and Git installations
echo "Verifying Java installation..."
java -version

echo "Verifying Git installation..."
git --version

# Install Maven only if it does not already exist
if [ ! -d "$INSTALL_DIR" ]; then

    echo "Downloading Apache Maven ${MAVEN_VERSION}..."

    cd /tmp

    wget -q "$MAVEN_URL"

    echo "Extracting Maven archive..."
    tar -xzf "$MAVEN_ARCHIVE"

    echo "Installing Maven into ${INSTALL_DIR}..."
    sudo mv "apache-maven-${MAVEN_VERSION}" "$INSTALL_DIR"

    echo "Removing downloaded archive..."
    rm -f "$MAVEN_ARCHIVE"

else

    echo "Maven already installed at ${INSTALL_DIR}."

fi

# Configure Maven environment variables if they are not already present
if ! grep -q "M2_HOME=${INSTALL_DIR}" ~/.bashrc 2>/dev/null; then

cat <<EOF >> ~/.bashrc

# Apache Maven Environment Variables
export M2_HOME=${INSTALL_DIR}
export PATH=\$PATH:\$M2_HOME/bin
EOF

    echo "Maven environment variables added."

else

    echo "Maven environment variables already configured."

fi

# Load Maven environment variables into the current session
export M2_HOME=${INSTALL_DIR}
export PATH=$PATH:$M2_HOME/bin

# Reload shell configuration
echo "Reloading shell configuration..."
source ~/.bashrc

# Verify Maven installation
echo "Verifying Maven installation..."
which mvn
mvn -version

echo ""
echo "======================================"
echo "Maven Installation Completed"
echo "Version      : ${MAVEN_VERSION}"
echo "Install Path : ${INSTALL_DIR}"
echo "======================================"
