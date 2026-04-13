#!/bin/sh

mkdir -p -- "${HOME}/.local/share/applications" || exit $?

ICONDIR="${SHAREDIR}/icons"

mkdir -p -- "${ICONDIR}" || exit $?

DESKTOPFILE="feh.desktop"

rm -f -- "${HOME}/.local/share/applications/${DESKTOPFILE}"
appjail cmd local "${X11APPJAIL_JAIL}" cp -a "usr/local/share/applications/${DESKTOPFILE}" "${HOME}/.local/share/applications" || exit $?
appjail cmd jaildir chown "${UID}:${GID}" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Exec=.+|Exec=${APPDIR}/START %u|" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee 's|^Name=(.+)|Name=\1 (AppJail)|' "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee 's|^Name\[(.+)\]=(.+)|Name[\1]=\2 (AppJail)|' "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Icon=.+|Icon=${ICONDIR}/feh.png|" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/local/share/icons/hicolor/48x48/apps/feh.png "${ICONDIR}/feh.png" || exit $?
appjail cmd jaildir chown "${UID}:${GID}" "${ICONDIR}/feh.png" || exit $?
