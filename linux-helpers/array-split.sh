#!/bin/bash

CSV=$1

[ -z "${CSV}" ] && echo "please provide an args array" && exit 1

CSV_AS_ARRAY=${1//,/ }

for element in $CSV_AS_ARRAY; do
    echo $element
done
