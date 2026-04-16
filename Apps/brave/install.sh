#!/bin/sh

mkdir -p -- "${HOME}/.local/share/applications" || exit $?

ICONDIR="${X11APPJAIL_SHAREDIR}/icons"

mkdir -p -- "${ICONDIR}" || exit $?

DESKTOPFILE="brave-browser.desktop"

rm -f -- "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}"
appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/share/applications/${DESKTOPFILE} "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}/${X11APPJAIL_PROFILE}-${DESKTOPFILE}" || exit $?
appjail cmd jaildir chown "${X11APPJAIL_UID}:${X11APPJAIL_GID}" "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Exec=/usr/bin/brave-browser-stable|Exec=${X11APPJAIL_APPDIR}/START|" "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Name=Brave Web Browser|Name=Brave Web Browser (AppJail:${X11APPJAIL_PROFILE})|" "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Icon=.+|Icon=${ICONDIR}/brave-browser.png|" "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}" || exit $?
appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/share/icons/hicolor/48x48/apps/brave-browser.png "${ICONDIR}/brave-browser.png" || exit $?
appjail cmd jaildir chown "${X11APPJAIL_UID}:${X11APPJAIL_GID}" "${ICONDIR}/brave-browser.png" || exit $?
