#!/bin/sh

mkdir -p -- "${HOME}/.local/share/applications" || exit $?

ICONDIR="${SHAREDIR}/icons"

mkdir -p -- "${ICONDIR}" || exit $?

DESKTOPFILE="org.gnome.Evince.desktop"

rm -f -- "${HOME}/.local/share/applications/${DESKTOPFILE}"
appjail cmd local "${X11APPJAIL_JAIL}" cp -a "usr/local/share/applications/${DESKTOPFILE}" "${HOME}/.local/share/applications" || exit $?
appjail cmd jaildir chown "${UID}:${GID}" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Exec=evince %U|Exec=${APPDIR}/START %u|" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^TryExec=evince|TryExec=${APPDIR}/START|" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Exec=evince --new-window|Exec=${APPDIR}/START --new-window|" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee 's|^Name=(.+)|Name=\1 (AppJail)|' "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee 's|^Name\[(.+)\]=(.+)|Name[\1]=\2 (AppJail)|' "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Icon=.+|Icon=${ICONDIR}/org.gnome.Evince.svg|" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/local/share/icons/hicolor/scalable/apps/org.gnome.Evince.svg "${ICONDIR}/org.gnome.Evince.svg" || exit $?
appjail cmd jaildir chown "${UID}:${GID}" "${ICONDIR}/org.gnome.Evince.svg" || exit $?
