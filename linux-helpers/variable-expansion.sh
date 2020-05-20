#!/bin/bash

TEST=$1

echo -n $TEST | grep "," > /dev/null 2>&1
GREP_EXIT=$?

[ -z $TEST ] && echo "args is empty" && exit 1

if [ $GREP_EXIT -eq 1 ]; then
    echo "args is single value"
else
    TEST_ARRAY=(${TEST//,/ })
    echo "args is array with ${#TEST_ARRAY[@]} entries"
    for argindex in ${!TEST_ARRAY[@]}; do
        echo "arg no. $argindex has value ${TEST_ARRAY[argindex]}"
    done
fi
