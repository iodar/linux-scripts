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
    apt install -y git
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

# install latest release of docker CE
function install_docker {
    # Update the apt package index:
    apt-get update
    # Install packages to allow apt to use a repository over HTTPS:
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    # set up the stable repository
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
    # update package index
    sudo apt-get update
    # install docker
    apt-get install -y docker-ce docker-ce-cli containerd.io
}

# install latests release of docker-compose
function install_docker_compose {
    # Run this command to download the latest version of Docker Compose:
    curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    # Apply executable permissions to the binary:
    chmod +x /usr/local/bin/docker-compose
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

# install postgres common and postgres client
function install_postgres_client {
    apt update
    apt install -y postgresql-client-common
    apt install -y postgresql-client-10
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

function change_colour_option_in_bashrc {
    # standard for root
    # colour support option is commented out
    COLOUR_SUPPORT_SEARCH_STRING="#force_color_prompt=yes"
    # enable by getting rid of the comment prefix
    COLOUR_SUPPORT_ON_STRING="force_color_prompt=yes"
    
    cat ~/.bashrc | sed "s/$COLOUR_SUPPORT_SEARCH_STRING/$COLOUR_SUPPORT_ON_STRING/" > ~/.bashrc_new
    # remove old bashrc and rename new one
    rm ~/.bashrc
    mv ~/.bashrc_new ~/.bashrc
}

# enable colour support on terminal
function activate_color_support_in_terminal {
    # greps wih fixed string in bashrc whether force_color_prompt
    if [ $(grep -Fxq "force_color_prompt=yes" ~/.bashrc; echo $?) -eq 0 ]; then
        echo "coloured terminal support already enabled in ~/.bashrc; skipping"
    else
        change_colour_option_in_bashrc
    fi
}

# prints versions of the all the installed software
function print_all_versions {
    echo -e "\n\n####### VERSIONS OF INSTALLED SOFTWARE #######\n\n"
    # node
    echo -e "node.js -> $(node -v)\n"
    # npm
    echo -e "npm -> $(npm -v)\n"
    # git
    echo -e "$(git --version)\n"
    # java
    echo -e "$($JAVA_PATH/jdk1.8.0_202/bin/java -version)"
    # postgres client
    echo -e "postgres -> $(psql --version)\n"
    # instructions for user
    echo -e "\nLog out and in again to apply all changes; env vars are not active yet\n"
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
    install_docker
    install_docker_compose
    install_postgres_client
    init_env
    activate_color_support_in_terminal
    print_all_versions
    clean_up_after_install
}


# M A I N
if [[ $(id -u) -eq 0 ]]; then
    perform_all
else
    echo -e "\nPlease retry with sudo rights\n"
fi
