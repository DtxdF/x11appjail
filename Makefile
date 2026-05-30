APPSDIR=	Apps
APPS!=		ls ${APPSDIR}
ARCH!=		uname -p
OUTDIR?=	assets/appscripts

TARGETS = ${APPS:C|(.+)|${OUTDIR}/\1-${ARCH}.appscript|}

.PHONY: all
all: build-all

.PHONY: build-all
build-all: ${TARGETS}

.PHONY: build
build:
	appscript -L -a ${ARCH} -o ${OUTDIR}/${APP}-${ARCH}.appscript ${APPSDIR}/${APP}

.PHONY: clean
clean:
	rm -f -- assets/appscripts/${APP}.appscript

.PHONY: cleanall
cleanall:
	find ${OUTDIR} -name '*.appscript' -exec rm -f {} +

${TARGETS}:
	@make build APP=${.TARGET:T:S/-${ARCH}.appscript//}
