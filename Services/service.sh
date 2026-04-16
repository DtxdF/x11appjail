#!/bin/sh

if [ -n "${X11APPJAIL_DEBUG}" ]; then
    set -x
fi

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

. "${BASEDIR}/../app.conf"
. "${BASEDIR}/../default.conf"

if ! which -s unixexec; then
    "${X11APPJAIL_EXEC_TOOL}" pkg install -y unixexec || exit $?
fi

if printf "%s" "${X11APPJAIL_SERVICE}" | grep -qEe '/' || [ ! -x "${BASEDIR}/${X11APPJAIL_SERVICE}/exec" ]; then
    echo "${0##*/}: ${X11APPJAIL_SERVICE}: No such service" >&2
    exit 1
fi

PROFILE=`printf "%s" "${X11APPJAIL_SERVICE_FROM}" | cut -s -d: -f2-`
test -n "${PROFILE}" || PROFILE="default"

APP=`printf "%s" "${X11APPJAIL_SERVICE_FROM}" | cut -s -d: -f1`
test -n "${APP}" || APP="${X11APPJAIL_SERVICE_FROM}"

# Need to redefine because we edited it previously.
X11APPJAIL_SERVICE_FROM="${APP}:${PROFILE}"
export X11APPJAIL_SERVICE_FROM

JAIL="x11appjail-${APP}-${X11APPJAIL_UID}_${PROFILE}"
DATADIR="${X11APPJAIL_DATA}/${JAIL}"

if [ ! -d "${DATADIR}" ]; then
    echo "${0##*/}: ${DATADIR}: No such directory"
    exit 1
fi

SERVICESDIR="${DATADIR}/.x11appjail/services"
SERVICEDIR="${SERVICESDIR}/${X11APPJAIL_SERVICE}"

mkdir -p -- "${SERVICEDIR}" || exit $?

SOCKET="${SERVICEDIR}/sock"

if [ -e "${SOCKET}" ] && [ ! -S "${SOCKET}" ]; then
    echo "${0##*/}: ${SOCKET##*/}: invalid file"
    exit 1
fi

AGENT="${SERVICEDIR}/agent"

cp -a -- "${BASEDIR}/${X11APPJAIL_SERVICE}/agent" "${AGENT}" || exit $?

if [ -f "${BASEDIR}/${X11APPJAIL_SERVICE}/agent.desktop" ]; then
    mkdir -p -- "${DATADIR}/.local/share/applications" || exit $?
    cp -a -- "${BASEDIR}/${X11APPJAIL_SERVICE}/agent.desktop" \
        "${DATADIR}/.local/share/applications/x11appjail-${X11APPJAIL_SERVICE}.desktop" || exit $?
fi

if [ -x "${BASEDIR}/${X11APPJAIL_SERVICE}/post" ]; then
    env JAIL="${JAIL}" \
        "${BASEDIR}/${X11APPJAIL_SERVICE}/post" || exit $?
fi

cd -- "${SERVICEDIR}"

while :; do
    unixexec "sock" "${BASEDIR}/${X11APPJAIL_SERVICE}/exec" || exit $?
done
