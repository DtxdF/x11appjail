APPS=nanonote librewolf tor-browser telegram-desktop chromium

all: build-all

build-all:
	@mkdir -p assets/appscripts
.for APP in ${APPS}
	@appscript -Lt -o ${PWD}/assets/appscripts/${APP}.appscript ${APP}
.endfor

build:
	@mkdir -p assets/appscripts
	@appscript -Lt -o ${PWD}/assets/appscripts/${APP}.appscript ${APP}
