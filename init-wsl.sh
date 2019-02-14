#!/bin/bash

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
# perform all the funtions above
function perform_all {
    perform_wsl_upgrade
    install_git
    install_node_js
}


# M A I N
if [[ $(id -u) -eq 0 ]]; then
    perform_all
else
    echo -e "\nPlease retry with sudo rights\n"
fi