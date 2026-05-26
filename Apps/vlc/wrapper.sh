#!/bin/sh

FILE="$1"
FILE="${FILE#file://}"

if [ -n "${FILE}" ] && [ -f "${FILE}" ]; then
    cat -- "${FILE}" | appjail cmd jexec "${X11APPJAIL_JAIL}" -U noroot -e DISPLAY=":${X11APPJAIL_DISPLAY}" "${X11APPJAIL_APPBIN}" -
else
    appjail cmd jexec "${X11APPJAIL_JAIL}" -U noroot -e DISPLAY=":${X11APPJAIL_DISPLAY}" "${X11APPJAIL_APPBIN}" -- "${FILE}"
fi
