#!/bin/sh

appjail cmd jexec "${X11APPJAIL_JAIL}" \
    -U noroot \
    -e DISPLAY=":${X11APPJAIL_DISPLAY}" \
    -e TZ="${TZ:-UTC}" \
        "${X11APPJAIL_APPBIN}" "$@"

ERRLEVEL=$?

appjail stop "${X11APPJAIL_JAIL}"

exit ${ERRLEVEL}
