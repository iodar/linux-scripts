#!/bin/bash

SOFTWARE_PATH=~/Software
JAVA_PATH="$SOFTWARE/java"
MAVEN_PATH="$SOFTWARE/maven"
NODE_PATH="$SOFTWARE/node"
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
        rm -r "$TMP_DIR"
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
# todo: 2020-05-21 iodar check if still needed
function perform_wsl_upgrade {
    apt update
    apt dist-upgrade -y
}

# # # # # # # # #
# install node js v12 (and npm)
function install_node_js {
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt-get install -y nodejs
}

# # # # # # # # #
# install git
function install_git {
    add-apt-repository -y ppa:git-core/ppa
    apt update
    apt install -y git
}

# # # # # # # # #
# downloads jdk 8 u202 from oracle
# installs jdk to ~/java
# exports JAVA_HOME
# adds JAVA_HOME to PATH
# todo: 2020-05-21 iodar global java path
# todo: 2020-05-21 iodar storing PATH in user env oder profile / bashrc
function download_and_install_java11 {
    create_java_dir
    OPEN_JDK_11_URL="https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz"
    OPEN_JDK_FILENAME=$(echo -n $OPEN_JDK_11_URL | grep -oP '[a-z0-9_\-\.]+.tar.gz$')
    # download openjdk
    curl "$OPEN_JDK_11_URL" -o "$TMP_DIR/$OPEN_JDK_FILENAME"
    # copy tar to java dir
    mv "$TMP_DIR/$OPEN_JDK_FILENAME" "$JAVA_PATH"
    # todo: 2020-05-20 iodar write file name to global variable
    # get filename of jdk dir inside the archive
    JAVA_JDK_DIR_NAME=$(tar -tf "$JAVA_PATH/$OPEN_JDK_FILENAME" | head -n 1 | grep -oP '^[a-z0-9\-\._]+')
    # extract files from archive
    tar -xf "$JAVA_PATH/$OPEN_JDK_FILENAME" -C "$JAVA_PATH/"
    # remove archive
    rm "$JAVA_PATH/$OPEN_JDK_FILENAME"
    # todo: 2020-05-20 iodar append bin path of jdk to profile / env
}

# install latest release of docker CE
function install_docker {
    # remove older version of docker
    apt-get remove docker docker-engine docker.io containerd runc
    # Update the apt package index:
    apt-get update
    # Install packages to allow apt to use a repository over HTTPS:
    apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
    # Add Docker's official GPG key
    curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | sudo apt-key add -

    # set up the stable repository
    # @see https://download.docker.com/linux/ubuntu/dists/
    # map for translation of codenames from linux mint to ubuntu
    MINT_TO_UBUNTU_MAP=([19]='bionic' [20]='focal')
    # if distro is 'Linux Mint' then use bionic, else use the ubuntu codename
    if [ $(grep -oq "Mint" /etc/issue; echo $?) -eq 0 ]; then
        # extract mint major release version
        LSB_MAJOR_RELEASE=$(sed 's|\..*||' <(lsb_release -rs))
        # map to ubuntu codename
        MINT_CODE_NAME=${MINT_TO_UBUNTU_MAP[LSB_MAJOR_RELEASE]}
        # add repo
        add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $MINT_CODE_NAME \
        stable"
    else
        add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
    fi

    # update package index
    apt update
    # install docker
    apt install -y docker-ce docker-ce-cli containerd.io
}

# install latests release of docker-compose
function install_docker_compose {
    # run this command to download the latest version of docker compose
    curl -L \
    "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o \
    /usr/local/bin/docker-compose
    # apply executable permissions to the binary:
    chmod +x /usr/local/bin/docker-compose
}

# downloads maven 3.6.0
# installs maven to ~/maven
# exports MAVEN_HOME
# adds MAVEN_HOME to PATH
# todo: 2020-05-21 maven path must be stored globally
function download_install_maven {
    create_maven_dir
    MAVEN_3_URL="http://apache.mirror.iphh.net/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz"
    MAVEN_ARCHIVE_NAME=$(echo -n $MAVEN_3_URL | grep -P '[\w\-\.]+.tar.gz$')
    curl $MAVEN_3_URL -o "$TMP_DIR/$MAVEN_ARCHIVE_NAME"

    MAVEN_DIR_NAME=$(tar -tf "$TMP_DIR/$MAVEN_ARCHIVE_NAME" | head -n 1 | grep -oP '^[\w\-\.]+')
    mv "$TMP_DIR/$MAVEN_DIR_NAME" "$MAVEN_PATH/"
    tar -xf "$MAVEN_PATH/$MAVEN_ARCHIVE_NAME" -C "$MAVEN_PATH/$MAVEN_DIR_NAME"
    rm "$MAVEN_PATH/$MAVEN_ARCHIVE_NAME"
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

# todo: 2020-05-21 iodar only activate this, if current release is not mint
# todo: 2020-05-21 iodar search on the internet, when this options needs to be activated
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
# todo: 2020-05-21 iodar fix java version
function print_all_versions {
    echo -e "\n\n####### VERSIONS OF INSTALLED SOFTWARE #######\n\n"
    # node
    echo -e "node.js -> $(node -v)\n"
    # npm
    echo -e "npm -> $(npm -v)\n"
    # git
    echo -e "git -> $(git --version | grep -oP "[\d\.]+")\n"
    # java
    # todo: 2020-05-20 iodar add command to extract java version: 
    # java -version 2>&1 | head -n 1 | awk '{print $3}' | grep -oP [0-9\.]+
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
    download_and_install_java11
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
