#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

. "${BASEDIR}/app.conf"

JAIL="${X11APPJAIL_JAIL:-${APPNAME}}"

XEPHYR_ARGS="\
-resizeable \
+extension RANDR \
+extension RENDER \
+extension GLX \
+extension XVideo \
+extension DOUBLE-BUFFER \
+extension SECURITY \
+extension DAMAGE \
+extension X-Resource \
-extension \
XINERAMA \
+extension MIT-SHM \
-nolisten tcp \
-title \"${APPDESCR}\""

exec appjail x11 "${JAIL}" \
    exec_start="ratpoison" \
    exec_user="noroot" \
    xephyr_user="${USER}" \
    xephyr_args="${XEPHYR_ARGS}" \
    xauthority="${XAUTHORITY:-${HOME}/.Xauthority}"
