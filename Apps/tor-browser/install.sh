#!/bin/sh

mkdir -p -- "${HOME}/.local/share/applications" || exit $?

ICONDIR="${X11APPJAIL_SHAREDIR}/icons"

mkdir -p -- "${ICONDIR}" || exit $?

DESKTOPFILE="tor-browser.desktop"

rm -f -- "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}"
appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/local/share/applications/${DESKTOPFILE} "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}" || exit $?
appjail cmd jaildir chown "${X11APPJAIL_UID}:${X11APPJAIL_GID}" "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Exec=/usr/local/lib/tor-browser/tor-browser|Exec=${X11APPJAIL_APPDIR}/START|" "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Name=(.+)|Name=\1 (AppJail:${X11APPJAIL_PROFILE})|" "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Icon=.+|Icon=${ICONDIR}/tor-browser.png|" "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}" || exit $?
appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/local/lib/tor-browser/browser/chrome/icons/default/default128.png "${ICONDIR}/tor-browser.png" || exit $?
appjail cmd jaildir chown "${X11APPJAIL_UID}:${X11APPJAIL_GID}" "${ICONDIR}/tor-browser.png" || exit $?
