#!/bin/sh

if [ $# -eq 0 ]; then
    set -- test
fi

exec kyua -c kyua.conf "$@"
