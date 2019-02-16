#!/bin/bash

JAVA_PATH=~/java
MAVEN_PATH=~/maven

# # # # # # # # #
# create maven path
function create_maven_path {
    mkdir -P $MAVEN_PATH
}

# # # # # # # # #
# create java dir for jdk
function create_java_dir {
    mkdir -P $JAVA_PATH
}

# # # # # # # # #
# update wsl and perform dist upgrade
function perform_wsl_upgrade {
    apt update
    apt dist-upgrade -y
}

# # # # # # # # #
# install node js v11 (and npm)
function install_node_js {
    curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
    sudo apt-get install -y nodejs
}

# # # # # # # # #
# install git
function install_git {
    echo -e "\n" | add-apt-repository ppa:git-core/ppa
    apt update
    apt install git -y
}

# # # # # # # # #
# downloads jdk 8 u202 from oracle
# installs jdk to ~/java
# exports JAVA_HOME
# adds JAVA_HOME to PATH
function download_and_install_java8_and_add_to_path {
    ORACLE_JDK_8_U202_URL="https://download.oracle.com/otn-pub/java/jdk/8u202-b08/1961070e4c9b4e26a04e7f5a083f551e/jdk-8u202-linux-x64.tar.gz"
    # oracle check whether the user has accepted the license agreement
    # when the cookie is not set, oracle denies the download
    ORACLE_ACCEPT_LICENSE_COOKIE='Cookie: oraclelicense=accept-securebackup-cookie'
    wget --no-cache -nc -c --no-check-certificate --header="$ORACLE_ACCEPT_LICENSE_COOKIE" $ORACLE_JDK_8_U202_URL
    # copy tar to java dir
    cp jdk-8u202-linux-x64.tar.gz $JAVA_PATH
    tar -xf $JAVA_PATH/jdk-8u202-linux-x64.tar.gz
}

function download_install_and_export_maven {
    MAVEN_3_URL="http://mirror.dkd.de/apache/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz"
    wget --no-cache -nc -c $MAVEN_3_URL
    cp apache-maven-3.6.0-bin.tar.gz $MAVEN_PATH
    tar -txf $MAVEN_PATH/apache-maven-3.6.0-bin.tar.gz
    # export MAVEN_HOME and add to path
    export MAVEN_HOME=$MAVEN_PATH
    PATH=$MAVEN_HOME/bin:$PATH
    export $PATH
}

# # # # # # # # #
# perform all the functions above
function perform_all {
    perform_wsl_upgrade
    install_git
    install_node_js
    download_and_install_java8_and_add_to_path
}


# M A I N
if [[ $(id -u) -eq 0 ]]; then
    perform_all
else
    echo -e "\nPlease retry with sudo rights\n"
fi
