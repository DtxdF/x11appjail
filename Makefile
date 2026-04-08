APPS=		nanonote librewolf tor-browser telegram-desktop chromium brave firefox
APPSUFX?=

all: build-all

build-all:
	@mkdir -p assets/appscripts
.for APP in ${APPS}
	@make build APP=${APP}
.endfor

build:
	@mkdir -p assets/appscripts
	@appscript -L -o assets/appscripts/${APP}${APPSUFX}.appscript ${APP}
