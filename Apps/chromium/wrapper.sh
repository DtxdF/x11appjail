#!/bin/sh

exec appjail cmd jexec "${X11APPJAIL_JAIL}" -U noroot -e DISPLAY=":${X11APPJAIL_DISPLAY}" "${X11APPJAIL_APPBIN}" --ignore-gpu-blocklist "$@"
