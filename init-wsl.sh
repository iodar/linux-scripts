#!/bin/bash

JAVA_PATH=~/java
MAVEN_PATH=~/maven
TMP_DIR=~/tmp_dir

# # # # # # # # # # # # # # # # # # # # # # #
# creates tmp dir to download all stuff into
function create_tmp_dir {
    mkdir -p "$TMP_DIR"
}

function clear_tmp_dir {
    if [ -d "$TMP_DIR" ]; then
        rm -r "$TMP_DIR"
    fi
}

function clean_up_after_install {
    if [ -d "$TMP_DIR" ]; then
        rm -r $TMP_DIR
    fi
}

# # # # # # # # #
# create maven path
function create_maven_dir {
    mkdir -p "$MAVEN_PATH"
}

# # # # # # # # #
# create java dir for jdk
function create_java_dir {
    mkdir -p "$JAVA_PATH"
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
function download_and_install_java8 {
    create_java_dir
    ORACLE_JDK_8_U202_URL="https://download.oracle.com/otn-pub/java/jdk/8u202-b08/1961070e4c9b4e26a04e7f5a083f551e/jdk-8u202-linux-x64.tar.gz"
    # oracle check whether the user has accepted the license agreement
    # when the cookie is not set, oracle denies the download
    ORACLE_ACCEPT_LICENSE_COOKIE='Cookie: oraclelicense=accept-securebackup-cookie'
    wget --no-cache -nc -c --no-check-certificate --header="$ORACLE_ACCEPT_LICENSE_COOKIE" $ORACLE_JDK_8_U202_URL -P "$TMP_DIR/"
    # copy tar to java dir
    mv "$TMP_DIR/jdk-8u202-linux-x64.tar.gz" "$JAVA_PATH"
    tar -xf "$JAVA_PATH/jdk-8u202-linux-x64.tar.gz" -C "$JAVA_PATH/"
    rm "$JAVA_PATH/jdk-8u202-linux-x64.tar.gz"
}

# downloads maven 3.6.0
# installs maven to ~/maven
# exports MAVEN_HOME
# adds MAVEN_HOME to PATH
function download_install_maven {
    create_maven_dir
    MAVEN_3_URL="http://mirror.dkd.de/apache/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz"
    wget --no-cache -nc -c $MAVEN_3_URL -P "$TMP_DIR/"
    mv "$TMP_DIR/apache-maven-3.6.0-bin.tar.gz" "$MAVEN_PATH/"
    tar -xf "$MAVEN_PATH/apache-maven-3.6.0-bin.tar.gz" -C "$MAVEN_PATH/"
    rm "$MAVEN_PATH/apache-maven-3.6.0-bin.tar.gz"
}

# # # # # # # # # # # # # # # # # # # # #
# download user env and append to bashrc
function init_env {
    USR_ENV_GITHUB_URL="https://raw.githubusercontent.com/iodar/linux-scripts/master/.user-env"
    wget --no-cache -nc -c $USR_ENV_GITHUB_URL -P ~/
    if [ $(grep -Fxq ". ~/user-env" ~/.bashrc; echo $?) -eq 0 ]; then
        echo "~/user-env is source in ~/bashrc already; skipping"
    else
        echo "# user defined aliases" >> ~/.bashrc
        echo ". ~/.user-env" >> ~/.bashrc
    fi
}

# # # # # # # # #
# perform all the functions above
function perform_all {
    create_tmp_dir
    perform_wsl_upgrade
    install_git
    install_node_js
    download_and_install_java8
    download_install_maven
    init_env
    clean_up_after_install
}


# M A I N
if [[ $(id -u) -eq 0 ]]; then
    perform_all
else
    echo -e "\nPlease retry with sudo rights\n"
fi
