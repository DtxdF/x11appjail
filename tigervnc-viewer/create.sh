#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

JAIL="${1:-tigervnc-viewer}"
TIGERVNC_SESSION="$2"

appjail makejail \
	-j "${JAIL}" \
	-o x11 \
	-o copydir="${BASEDIR}/files" \
	-o file="/etc/rc.conf.local" \
	-o template="${BASEDIR}/template.conf" \
	-o virtualnet=":<random> default" \
	-o nat -- \
        --tigervnc_session "${TIGERVNC_SESSION}"
