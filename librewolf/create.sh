#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

JAIL="${1:-librewolf}"

appjail makejail \
	-j "${JAIL}" \
	-o x11 \
	-o copydir="${BASEDIR}/files" \
	-o file="/etc/rc.conf.local" \
	-o template="${BASEDIR}/template.conf" \
	-o virtualnet=":<random> default" \
	-o nat
