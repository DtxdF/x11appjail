#!/bin/sh

ME=`readlink -f -- "$0"` || exit 1
SELF=`dirname -- "${ME}"` || exit 1

exec signify -G -n -c "tests@example.org (tests)" -p "${SELF}/key.pub" -s "${SELF}/key.sec"
