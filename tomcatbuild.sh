#!/usr/bin/env bash

#=========================================
#     Apache Tomcat Installation Script
#=========================================
#
# Target OS:
# Ubuntu 22.04 / 24.04
#
#==============================
# Package Manager Notes:
# Ubuntu/Debian  -> apt
# Amazon Linux   -> dnf
# RHEL/CentOS    -> yum or dnf
#==============================
#
# This script installs:
# - OpenJDK 11
# - OpenJDK 17
# - Apache Tomcat 9
#
# Tomcat is installed into:
# /opt/tomcat
#
# The script is idempotent and can be executed
# multiple times without breaking an existing installation.
#

set -euo pipefail

#
# Prevent execution as root.
# The script already uses sudo where required.
#

if [ "$EUID" -eq 0 ]; then
    echo "❌ DO NOT RUN THIS SCRIPT WITH SUDO."
    echo "❌ RUN: ./tomcatbuild.sh"
    exit 1
fi

TOMCAT_VERSION="9.0.108"
TOMCAT_ARCHIVE="apache-tomcat-${TOMCAT_VERSION}.tar.gz"
TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/${TOMCAT_ARCHIVE}"
INSTALL_DIR="/opt/tomcat"

echo "🚀========== APACHE TOMCAT INSTALLATION =========="

#==================================================
# Configure hostname only if it is not already set.
#==================================================

CURRENT_HOSTNAME=$(hostname)

if [ "${CURRENT_HOSTNAME}" = "tomcatbuild" ]; then
    echo "✅ HOSTNAME ALREADY CONFIGURED."
else
    echo "⚙️  SETTING HOSTNAME TO TOMCATBUILD..."
    sudo hostnamectl set-hostname tomcatbuild
fi

#==========================
# Refresh package metadata.
#==========================

echo "📦 UPDATING PACKAGE REPOSITORIES..."
sudo apt update -y

#====================================================
# Install common administration and DevOps utilities.
#====================================================

echo "📦 INSTALLING REQUIRED UTILITIES..."
sudo apt install -y wget nano tree unzip git

#===============================
# Install OpenJDK 11 if missing.
#===============================

if dpkg -s openjdk-11-jdk >/dev/null 2>&1; then
    echo "✅ OPENJDK 11 ALREADY INSTALLED."
else
    echo "☕ INSTALLING OPENJDK 11..."
    sudo apt install -y openjdk-11-jdk
fi

#===============================
# Install OpenJDK 17 if missing.
#===============================

if dpkg -s openjdk-17-jdk >/dev/null 2>&1; then
    echo "✅ OPENJDK 17 ALREADY INSTALLED."
else
    echo "☕ INSTALLING OPENJDK 17..."
    sudo apt install -y openjdk-17-jdk
fi

#==========================
# Verify Java installation.
#==========================

echo "☕ VERIFYING JAVA INSTALLATION..."
java -version

#========================
# Install UFW if missing.
#========================

if command -v ufw >/dev/null 2>&1; then
    echo "✅ UFW ALREADY INSTALLED."
else
    echo "🛡️ INSTALLING UFW..."
    sudo apt install -y ufw
fi

#==================================
# Configure Tomcat firewall access.
#==================================

echo "🛡️ CONFIGURING UFW..."

if systemctl is-active ufw >/dev/null 2>&1; then

    sudo ufw allow 8080/tcp
    echo "✅ UFW RULE ADDED FOR PORT 8080."

else

    echo "⚠️  UFW NOT ACTIVE. SKIPPING PORT CONFIGURATION."

fi

#=============================================
# Install Tomcat if it does not already exist.
#=============================================

if [ -d "${INSTALL_DIR}" ]; then

    echo "✅ TOMCAT ALREADY INSTALLED AT ${INSTALL_DIR}."

else

    echo "⬇️  DOWNLOADING APACHE TOMCAT ${TOMCAT_VERSION}..."

    cd /tmp

    wget -q "${TOMCAT_URL}"

    echo "📦 EXTRACTING TOMCAT ARCHIVE..."

    tar -xzf "${TOMCAT_ARCHIVE}"

    echo "📁 INSTALLING TOMCAT INTO ${INSTALL_DIR}..."

    sudo mv "apache-tomcat-${TOMCAT_VERSION}" "${INSTALL_DIR}"

    echo "🔐 CONFIGURING TOMCAT PERMISSIONS..."

    sudo chmod +x ${INSTALL_DIR}/bin/*.sh

    echo "🗑️ REMOVING DOWNLOADED ARCHIVE..."

    rm -f "${TOMCAT_ARCHIVE}"

fi

#========================================
# Configure Tomcat environment variables.
#========================================

if grep -q "CATALINA_HOME=${INSTALL_DIR}" ~/.bashrc 2>/dev/null; then

    echo "✅ TOMCAT ENVIRONMENT VARIABLES ALREADY CONFIGURED."

else

    echo "" >> ~/.bashrc
    echo "# Apache Tomcat Environment Variables" >> ~/.bashrc
    echo "export CATALINA_HOME=${INSTALL_DIR}" >> ~/.bashrc
    echo "export CATALINA_BASE=${INSTALL_DIR}" >> ~/.bashrc
    echo 'export PATH=$PATH:$CATALINA_HOME/bin' >> ~/.bashrc

    echo "⚙️  TOMCAT ENVIRONMENT VARIABLES ADDED."

fi

#=========================================
# Create Tomcat systemd service if missing.
#=========================================

if [ -f /etc/systemd/system/tomcat.service ]; then

    echo "✅ TOMCAT SYSTEMD SERVICE ALREADY EXISTS."

else

    echo "⚙️  CREATING TOMCAT SYSTEMD SERVICE..."

    sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat Application Server
After=network.target

[Service]
Type=forking

User=ubuntu
Group=ubuntu

Environment=CATALINA_HOME=${INSTALL_DIR}
Environment=CATALINA_BASE=${INSTALL_DIR}

ExecStart=${INSTALL_DIR}/bin/startup.sh
ExecStop=${INSTALL_DIR}/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    echo "🔄 RELOADING SYSTEMD DAEMON..."
    sudo systemctl daemon-reload

fi

#=======================
# Enable Tomcat service.
#=======================

if systemctl is-enabled tomcat >/dev/null 2>&1; then
    echo "✅ TOMCAT SERVICE ALREADY ENABLED."
else
    echo "⚙️  ENABLING TOMCAT SERVICE..."
    sudo systemctl enable tomcat
fi

#======================
# Start Tomcat service.
#======================

if systemctl is-active tomcat >/dev/null 2>&1; then
    echo "✅ TOMCAT SERVICE ALREADY RUNNING."
else
    echo "▶️  STARTING TOMCAT SERVICE..."
    sudo systemctl start tomcat
fi

#======================
# Verify installation.
#======================

echo "🔍 VERIFYING TOMCAT INSTALLATION..."

echo "======================================"
echo "🔍 TOMCAT SERVICE STATUS"
echo "======================================"
systemctl is-active tomcat

echo "======================================"
echo "📋 DETAILED SERVICE STATUS"
echo "======================================"
systemctl status tomcat --no-pager

echo "======================================"
echo "🌐 CHECKING TOMCAT WEB RESPONSE"
echo "======================================"
curl -s http://localhost:8080 | grep -m 1 -i "Apache Tomcat"
curl -I http://localhost:8080 2>/dev/null | head -n 1

echo "======================================"
echo "✅ TOMCAT INSTALLATION COMPLETED"
echo "Version      : ${TOMCAT_VERSION}"
echo "Install Path : ${INSTALL_DIR}"
echo "======================================"
