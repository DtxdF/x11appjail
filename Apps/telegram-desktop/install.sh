#!/bin/sh

mkdir -p -- "${HOME}/.local/share/applications" || exit $?

ICONDIR="${SHAREDIR}/icons"

mkdir -p -- "${ICONDIR}" || exit $?

DESKTOPFILE="org.telegram.desktop.desktop"

rm -f "${HOME}/.local/share/applications/${DESKTOPFILE}"
appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/local/share/applications/org.telegram.desktop.desktop "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
appjail cmd jaildir chown "${UID}:${GID}" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Exec=Telegram (.+)|Exec=${APPDIR}/START \1|" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^TryExec=Telegram|TryExec=${APPDIR}/START|" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee 's|^Name=(.+)|Name=\1 (AppJail)|' "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Icon=org\.telegram\.desktop|Icon=${ICONDIR}/org.telegram.desktop.png|" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/local/share/icons/hicolor/48x48/apps/org.telegram.desktop.png "${ICONDIR}/org.telegram.desktop.png" || exit $?
appjail cmd jaildir chown "${UID}:${GID}" "${ICONDIR}/org.telegram.desktop.png" || exit $?
