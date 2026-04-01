#!/bin/sh

mkdir -p -- "${HOME}/.local/share/applications" || exit $?
mkdir -p -- "${HOME}/.local/share/pixmaps" || exit $?

DESKTOPFILE="librewolf.desktop"

appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/local/share/applications/${DESKTOPFILE} "${HOME}/.local/share/applications" || exit $?
appjail cmd jaildir chown "${UID}:${GID}" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Exec=librewolf (.+)|Exec=${APPDIR}/START \1|" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee 's|^Name=(.+)|Name=\1 (AppJail)|' "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee 's|^Name\[(.+)\]=(.+)|Name[\1]=\2 (AppJail)|' "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/local/lib/librewolf/browser/chrome/icons/default/default48.png "${HOME}/.local/share/pixmaps/librewolf.png" || exit $?
appjail cmd jaildir chown "${UID}:${GID}" "${HOME}/.local/share/pixmaps/librewolf.png" || exit $?
