#!/bin/sh

FILE="$1"
FILE="${FILE#file://}"

if [ "${FILE}" = "--new-window" ]; then
    exec appjail cmd jexec "${X11APPJAIL_JAIL}" -U noroot -e DISPLAY=":${X11APPJAIL_DISPLAY}" "${X11APPJAIL_APPBIN}" --new-window
fi

set --

PATHNAME="${FILE}"

if [ -f "${FILE}" ]; then
    FILE=`realpath -- "${FILE}"` || exit $?
    CHECKSUM=`sha256 -q -- "${FILE}"` || exit $?
    JAILDIR=`appjail cmd local "${X11APPJAIL_JAIL}" realpath .` || exit $?
    PATHNAME="/noroot/${CHECKSUM}.pdf"
    OUTPUT="${JAILDIR}${PATHNAME}"

    if [ -z "${X11APPJAIL_WITH_CACHE}" ] || [ ! -f "${OUTPUT}" ]; then
        if [ -n "${X11APPJAIL_WITH_PUCK}" ]; then
            appjail makejail \
                -f gh+AppJail-makejails/puck \
                -o container="args:--pull" \
                -V PUCK_RESOLUTION="${X11APPJAIL_PUCK_RESOLUTION:-300}" \
                -V PUCK_BATCH="${X11APPJAIL_PUCK_BATCH:-50}" \
                -V PUCK_COMPRESSION="0" \
                -- \
                    --puck_file "${FILE}" \
                    --puck_output "${OUTPUT}" || exit $?
        else
            appjail cmd local "${X11APPJAIL_JAIL}" cp -a "${FILE}" "${OUTPUT}" || exit $?
        fi
    fi
    UID=`id -u` || exit $?
    GID=`id -g` || exit $?
    appjail cmd local "${X11APPJAIL_JAIL}" chmod 640 "${OUTPUT}"
    appjail cmd local "${X11APPJAIL_JAIL}" chown "${UID}:${GID}" "${OUTPUT}"
fi

set -- "$@" -f

if [ -n "${PATHNAME}" ]; then
    set -- "$@" -- "${PATHNAME}"
fi

exec appjail cmd jexec "${X11APPJAIL_JAIL}" -U noroot -e DISPLAY=":${X11APPJAIL_DISPLAY}" "${X11APPJAIL_APPBIN}" "$@"
