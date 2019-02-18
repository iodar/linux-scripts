#!/bin/bash

function parse_install_values {
    install_options_string=$1
    
}

while [ $# -gt 0 ]; do
    key="$1"

    case $key in
        --install=*)
        # get the value of the command line option
        # parse the comma separated values
        *)
        # do nothing
    esac
done
        