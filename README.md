# Apache Maven & Apache Tomcat Provisioning Automation

## Overview

This project contains idempotent Bash scripts that provision an Ubuntu-based EC2 instance for Java application build and deployment activities.

The scripts automate the installation and configuration of:

* OpenJDK 11
* OpenJDK 17
* Apache Maven
* Apache Tomcat 9
* Common Linux administration utilities
* Environment variables required for Java-based tooling

The objective is to create a repeatable and consistent Java build and deployment environment that can be provisioned multiple times without causing configuration drift or duplicate installations.

---

## Project Structure

```text
maven-apachetomcat-build/
├── screenshots/
│   ├── maven-validation.png
│   ├── tomcat-service-validation.png
│   └── tomcat-homepage.png
├── mavenbuild.sh
├── tomcatbuild.sh
└── README.md
```

---

## Components

### Apache Maven Build Server

The Maven provisioning script installs and configures:

* OpenJDK 11
* OpenJDK 17
* Apache Maven

Maven is installed into:

```text
/opt/maven
```

The script also configures:

```text
M2_HOME
PATH
```

allowing Maven commands to be executed from any directory.

---

### Apache Tomcat Application Server

The Tomcat provisioning script installs and configures:

* Apache Tomcat 9
* Required Java runtime
* Tomcat service configuration
* Tomcat startup and management commands

Tomcat is installed into:

```text
/opt/tomcat
```

and configured to run as a systemd service.

---

## What These Scripts Do

The provisioning scripts perform the following tasks:

### Host Configuration

Configure the server hostname where required.

### Utility Installation

Install common administration and DevOps utilities:

```text
wget
nano
tree
unzip
git
```

### Java Installation

Install:

* OpenJDK 11
* OpenJDK 17

These Java Development Kits allow the server to support both legacy and modern Java applications.

### Environment Configuration

Configure the required environment variables for Java-based tooling.

### Validation

Verify:

* Java installation
* Git installation
* Maven installation
* Tomcat installation

before completing execution.

---

## Idempotency

Both provisioning scripts are designed to be idempotent.

This means they can be executed multiple times without creating duplicate configurations or damaging an existing installation.

Examples:

* Hostname changes only occur when required.
* Java packages are checked before installation.
* Maven is only installed when it does not already exist.
* Tomcat is only installed when it does not already exist.
* Environment variables are only added when missing.
* Existing services are detected before recreation.

---

## Prerequisites

Before running the scripts, ensure you have:

* An AWS account
* An Ubuntu EC2 instance
* SSH access to the instance
* A user account with sudo privileges

Recommended instance size:

```text
t2.medium or larger
```

> **Note:** During testing, a t3.micro instance (1 GB RAM) experienced resource constraints while running Java-based services. A t2.medium or larger instance is recommended for Apache Maven and Apache Tomcat workloads.

---

## Installation

Clone the repository:

```bash
git clone <repository-url>
```

Move into the project directory:

```bash
cd maven-apachetomcat-build
```

---

## Apache Maven Provisioning

Make the script executable:

```bash
chmod +x mavenbuild.sh
```

Run the script:

```bash
./mavenbuild.sh
```

---

## Apache Tomcat Provisioning

Make the script executable:

```bash
chmod +x tomcatbuild.sh
```

Run the script:

```bash
./tomcatbuild.sh
```

---

## Package Manager Notes

This project is written for Ubuntu systems and uses the APT package manager.

APT package examples used by this project:

```bash
sudo apt install openjdk-11-jdk
sudo apt install openjdk-17-jdk
```

If using another Linux distribution, replace the package manager commands with the appropriate equivalent.

### Ubuntu / Debian

```bash
sudo apt install openjdk-11-jdk
sudo apt install openjdk-17-jdk
```

### Amazon Linux 2023

```bash
sudo dnf install java-11-amazon-corretto-devel
sudo dnf install java-17-amazon-corretto-devel
```

### RHEL 8 / RHEL 9

```bash
sudo dnf install java-11-openjdk-devel
sudo dnf install java-17-openjdk-devel
```

### CentOS 7

```bash
sudo yum install java-11-openjdk-devel
sudo yum install java-17-openjdk-devel
```

### Fedora

```bash
sudo dnf install java-11-openjdk-devel
sudo dnf install java-17-openjdk-devel
```

---

## Verification

Verify Java:

```bash
java -version
```

Verify Maven:

```bash
mvn -version
```

Verify Tomcat:

```bash
systemctl status tomcat
```

Verify Tomcat HTTP Response:

```bash
curl -I http://localhost:8080
```

Expected Maven installation directory:

```text
/opt/maven
```

Expected Tomcat installation directory:

```text
/opt/tomcat
```

---

## Validation & Test Results

### Maven Idempotency Validation & Verification

The screenshot below shows a successful re-execution of the Maven provisioning script.

The output confirms that:

* OpenJDK 11 was already installed
* OpenJDK 17 was already installed
* Apache Maven was already installed
* Maven environment variables were already configured
* The script completed successfully without creating duplicate configurations
* Maven was successfully resolved from `/opt/maven/bin/mvn`
* Maven was verified successfully using `mvn -version`

![Maven Validation](screenshots/maven-validation.png)

---

### Apache Tomcat Service Validation

The screenshot below shows validation performed directly from the server.

The validation confirms that:

* The Tomcat service is active
* Tomcat is listening on port 8080
* HTTP requests return a successful response
* The Tomcat systemd service is functioning correctly

Validation commands used:

```bash
systemctl is-active tomcat
curl -I http://localhost:8080
sudo ss -tulpn | grep 8080
```

![Tomcat Service Validation](screenshots/tomcat-service-validation.png)

---

### Apache Tomcat Deployment Validation

The screenshot below shows Apache Tomcat 9.0.108 successfully deployed and accessible through the EC2 instance on port 8080.

The validation confirms that:

* Apache Tomcat 9.0.108 was installed successfully
* The Tomcat systemd service was created successfully
* Tomcat was enabled to start automatically at boot
* The service started successfully
* Port 8080 was reachable
* The Tomcat landing page was accessible from a web browser
* HTTP responses were returned successfully
* The installation was validated through a public EC2 endpoint

Validation was performed from both the server and a web browser to confirm service availability and external accessibility.

![Tomcat Homepage](screenshots/tomcat-homepage.png)

---

## Summary

This project demonstrates the use of idempotent Bash scripting to automate the provisioning of a Java build and deployment environment on Ubuntu.

The solution provisions:

* OpenJDK 11
* OpenJDK 17
* Apache Maven
* Apache Tomcat 9

while ensuring that repeated executions do not create duplicate configurations or modify a correctly configured environment.

The result is a repeatable provisioning process suitable for development, testing, learning environments, and infrastructure automation demonstrations.

---

### 🚀 Final Note

These scripts were created to demonstrate practical Linux administration, Bash scripting, Java platform provisioning, service management, and infrastructure automation techniques.

Feel free to use, modify, and extend them for your own environments and learning projects.

Happy Automating!
