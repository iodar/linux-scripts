#!/bin/bash

# globals
SCRIPT_NAME=$0
# install flags
INSTALL_ALL=0
INSTALL_NOT_ALL=0
# custom install flags
INSTALL_GIT=0
INSTALL_NODE=0
INSTALL_JAVA=0
INSTALL_MAVEN=0
INSTALL_PSQL=0
INSTALL_ENV=0
INSTALL_DOCKER=0
INSTALL_DOCKER_COMPOSE=0

function print_usage {
    usage="
    usage: $SCRIPT_NAME [OPTION]\n
    \nOPTIONS\n
        \t-a, --all                 \t\t Starts the installation of all available software.\n
                                    \t\t\t\t # maven, git, docker, docker-compose, node, psql\n
                                    \t\t\t\t # java 8, user-environment\n
    \n
        \t-i=[packages] OR \n
        \t--install=[packages]            \t Specify the software you like to install.\n
                                    \t\t\t\t Use a comma separated list to specify the\n
                                    \t\t\t\t install options.\n
                                    \t\t\t\t EXAMPLE:\n
                                    \t\t\t\t \t --install=git,node,env\n
                                    \t\t\t\t \t -i=git,node,env\n
    \n
                                    \t\t\t\t # Available options:\n
                                    \t\t\t\t ## java -> Java JDK 8 u202\n
                                    \t\t\t\t ## maven -> Maven 3.6.0\n
                                    \t\t\t\t ## node -> latest release of node.js and npm\n
                                    \t\t\t\t ## psql -> psql client 10.x\n
                                    \t\t\t\t ## docker -> latest release of Docker CE\n
                                    \t\t\t\t ## docker-compose ->\tlatest release of\n
                                    \t\t\t\t ## \t\t\tdocker-compose\n
                                    \t\t\t\t ## env -> \tlatest version of the custom user\n
                                    \t\t\t\t ## \n
                                    \t\t\t\t ## \t\tNEEDED \tif docker OR maven OR java\n
                                    \t\t\t\t ## \t\t\tis installed\n
    "
    echo -e $usage
}

function handle_cmd_line_options {
    while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -a|--all)
            # do stuff
            INSTALL_ALL=1
            shift
            ;;
        -i=*|--install=*)
            # do other stuff
            INSTALL_NOT_ALL=1
            options=${key#*=}
            extract_cmd_line_options "$options"
            shift
            ;;
        -i|--install)
            echo -e "ERROR: Missing install options. See usage.\n"
            shift
            ;;
        *)
            echo -e "ERROR: Option '$key' is not recognised. Ignoring this option.\n"
            shift
            ;;
        esac
    done

    # validate cmd line options
    if [[ $INSTALL_ALL -eq 1 ]] && [[ $INSTALL_NOT_ALL -eq 1 ]]; then
        echo -e "ERROR: Combination of -a or --all and --install is not allowed\n"
        EXIT=1
    else
        EXIT=0
    fi
    
    return $EXIT
}

function check_for_cmd_line_options {
    CMD_OPTIONS_EXIT=0
    if [[ $# -le 0 ]]; then
        echo -e "ERROR: At least one command line option must be specified.\n"
        print_usage
    else
        handle_cmd_line_options "$@"
        CMD_OPTIONS_EXIT=$(echo $?)
        if [[ $CMD_OPTIONS_EXIT -eq 1 ]]; then
            echo -e "ERROR: Could not process command line options. Stopping.\n"
        fi
    fi
}

function extract_cmd_line_options {
    install_options=$1
    
    # check for empty string of install options
    # if empty then there are no install flags -> throw error
    if [[ ${#install_options} -eq 0 ]]; then
        echo -e "ERROR: No install flags specified after equals sign. See usage.\n"
    else
        # expands var and replaces ',' with ' ' and
        # returns an array
        install_options_array=(${install_options//,/ })

        # iterates over the array and prints each
        # value of the array on a new line
        for i in "${install_options_array[@]}"; do
            case $i in 
                git)
                    INSTALL_GIT=1
                    ;;
                node)
                    INSTALL_NODE=1
                    ;;
                java)
                    INSTALL_JAVA=1
                    ;;
                maven)
                    INSTALL_MAVEN=1
                    ;;
                psql)
                    INSTALL_PSQL=1
                    ;;
                docker)
                    INSTALL_DOCKER=1
                    ;;
                docker-compose)
                    INSTALL_DOCKER_COMPOSE=1
                    ;;
                env)
                    INSTALL_ENV=1
                    ;;
                *)
                    echo -e "ERROR: Install flag '$i' is not recognised. Ignoring this option.\n"
                    ;;
            esac
        done
    fi
}

check_for_cmd_line_options "$@"
