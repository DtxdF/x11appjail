#!/bin/sh

exec appjail cmd jexec "${X11APPJAIL_JAIL}" -U noroot -e DISPLAY=":${X11APPJAIL_DISPLAY}" \
    dbus-run-session -- "${X11APPJAIL_APPBIN}" --ignore-gpu-blocklist "$@"
