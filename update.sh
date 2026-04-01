#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

APP="${1}"

test -n "${APP}" || exit 1

for FILE in APPSCRIPT create.sh start-server.sh startup.sh; do
    cp -a "${BASEDIR}/${FILE}" "${BASEDIR}/${APP}/${FILE}" || exit $?
done
