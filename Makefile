MKDIR?=mkdir -p
FIND?=find
INSTALL?=install
SED?=sed -i ''
RM?=rm -f
PREFIX?=/usr/local
MANDIR?=${PREFIX}/share/man
LN?=ln -f

X11APPJAIL_VERSION?=1.1.0

all: install

install:
	${MKDIR} -m 755 "${DESTDIR}${PREFIX}/share/x11appjail"
	${MKDIR} -m 755 "${DESTDIR}${MANDIR}/man1"
	${MKDIR} -m 755 "${DESTDIR}${MANDIR}/man5"
	${MKDIR} -m 755 "${DESTDIR}${PREFIX}/bin"
	${MKDIR} -m 755 "${DESTDIR}${PREFIX}/share/x11appjail/appscript"
	${FIND} share/x11appjail/appscript -mindepth 1 -exec ${INSTALL} -m 555 {} "${DESTDIR}${PREFIX}/{}" \;
	${MKDIR} -m 755 "${DESTDIR}${PREFIX}/share/x11appjail/scaffold"
.for s in create install run uninstall X
	${INSTALL} -m 555 share/x11appjail/scaffold/${s} "${DESTDIR}${PREFIX}/share/x11appjail/scaffold/${s}"
.endfor
.for f in Makejail template.conf
	${INSTALL} -m 444 share/x11appjail/scaffold/${f} "${DESTDIR}${PREFIX}/share/x11appjail/scaffold/${f}"
.endfor
	${MKDIR} -m 755 "${DESTDIR}${PREFIX}/lib/x11appjail"
	${INSTALL} -m 644 lib/common "${DESTDIR}${PREFIX}/lib/x11appjail/common"
	${MKDIR} -m 755 "${DESTDIR}${PREFIX}/libexec/x11appjail"
.for s in appsiz attr exec veriexec destroy-jail remove run-cmd print-display map-exec
	${INSTALL} -m 555 libexec/${s} "${DESTDIR}${PREFIX}/libexec/x11appjail/${s}"
.endfor
	${LN} "${DESTDIR}${PREFIX}/libexec/x11appjail/run-cmd" "${DESTDIR}${PREFIX}/libexec/x11appjail/login"
	${LN} "${DESTDIR}${PREFIX}/libexec/x11appjail/attr" "${DESTDIR}${PREFIX}/libexec/x11appjail/sys-attr"
	${MKDIR} -m 755 "${DESTDIR}${PREFIX}/libexec/x11appjail/service.d"
.for s in OpenURL Notification
	${MKDIR} -m 755 "${DESTDIR}${PREFIX}/libexec/x11appjail/service.d/${s}"
	cd libexec/service.d/${s}; ${FIND} . -mindepth 1 -exec ${INSTALL} -m 555 {} "${DESTDIR}${PREFIX}/libexec/x11appjail/service.d/${s}/{}" \;
.endfor
	${MKDIR} -m 755 "${DESTDIR}${PREFIX}/libexec/x11appjail/misc"
.for s in simple-desktop-file-utils.sh
	${INSTALL} -m 555 libexec/misc/${s} "${DESTDIR}${PREFIX}/libexec/x11appjail/misc/${s}"
.endfor
	${INSTALL} -m 444 share/man/man1/x11appjail.1 "${DESTDIR}${MANDIR}/man1/x11appjail.1"
	${SED} -i '' -e 's|%%PREFIX%%|${PREFIX}|' "${DESTDIR}${MANDIR}/man1/x11appjail.1"
	${INSTALL} -m 444 share/man/man5/x11appjail-spec.5 "${DESTDIR}${MANDIR}/man5/x11appjail-spec.5"
	${INSTALL} -m 555 x11appjail.sh "${DESTDIR}${PREFIX}/bin/x11appjail"
	${SED} -e 's|%%VERSION%%|${X11APPJAIL_VERSION}|' "${DESTDIR}${PREFIX}/bin/x11appjail"

uninstall:
	${RM} "${DESTDIR}${PREFIX}/bin/x11appjail"
	${RM} -r "${DESTDIR}${PREFIX}/share/x11appjail"
	${RM} "${DESTDIR}${MANDIR}/man1/x11appjail.1"
	${RM} -r "${DESTDIR}${PREFIX}/libexec/x11appjail"

docs:
	@mandoc -T ascii share/man/man1/x11appjail.1 | col -b | tail +3 | sed -e '$$d' | sed -e '$$d' | sed -e 's|%%PREFIX%%|${PREFIX}|' > README.txt
