#!/bin/sh

mkdir -p -- "${HOME}/.local/share/applications" || exit $?

DESKTOPFILE="librewolf.desktop"

appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/local/share/applications/${DESKTOPFILE} "${HOME}/.local/share/applications" || exit $?
appjail cmd jaildir chown "${UID}:${GID}" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Exec=librewolf (.+)|Exec=${APPDIR}/START \1|" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee 's|^Name=(.+)|Name=\1 (AppJail)|' "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee 's|^Name\[(.+)\]=(.+)|Name[\1]=\2 (AppJail)|' "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Icon=.+|Icon=${ICONDIR}/librewolf.png|" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/local/lib/librewolf/browser/chrome/icons/default/default48.png "${ICONDIR}/librewolf.png" || exit $?
appjail cmd jaildir chown "${UID}:${GID}" "${ICONDIR}/librewolf.png" || exit $?
