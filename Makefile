APPS=nanonote librewolf tor-browser telegram-desktop chromium brave

all: build-all

build-all:
	@mkdir -p assets/appscripts
.for APP in ${APPS}
	@appscript -L -o ${PWD}/assets/appscripts/${APP}.appscript ${APP}
.endfor

build:
	@mkdir -p assets/appscripts
	@appscript -L -o ${PWD}/assets/appscripts/${APP}.appscript ${APP}
