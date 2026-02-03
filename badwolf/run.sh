#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

JAIL="${1:-badwolf}"

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
-nolisten tcp"

appjail x11 "${JAIL}" \
	exec_start="ratpoison" \
	exec_user="badwolf" \
	xephyr_user="${USER}" \
	xephyr_args="${XEPHYR_ARGS}"
