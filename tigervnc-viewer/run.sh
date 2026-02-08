#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

JAIL="${1:-tigervnc-viewer}"

XEPHYR_DISPLAY=`appjail x11 "${JAIL}" assign_only` || exit $?

TITLE="${2:-${JAIL}: tigervnc-viewer from :${XEPHYR_DISPLAY}}"

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
-title \"${TITLE}\""

exec appjail x11 "${JAIL}" \
	exec_start="vncviewer /data/session.tigervnc" \
	exec_user="tigervnc-viewer" \
	xephyr_user="${USER}" \
	xephyr_args="${XEPHYR_ARGS}"
