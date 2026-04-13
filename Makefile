APPSDIR=	Apps
APPS!=		ls ${APPSDIR}
APPSUFX?=
OUTDIR?=	assets/appscripts

TARGETS = ${APPS:C|(.+)|${OUTDIR}/\1${APPSUFX}.appscript|}

.PHONY: all
all: build-all

.PHONY: build-all
build-all: ${TARGETS}

.PHONY: build
build:
	@mkdir -p ${OUTDIR}
	appscript -L -o ${OUTDIR}/${APP}.appscript ${APPSDIR}/${APP}

.PHONY: clean
clean:
	rm -f -- assets/appscripts/${APP}.appscript

.PHONY: cleanall
cleanall:
	find ${OUTDIR} -name '*.appscript' -exec rm -f {} +

${TARGETS}:
	@make build APP=${.TARGET:T:S/${APPSUFX}.appscript//}
