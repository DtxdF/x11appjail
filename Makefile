APPS=nanonote librewolf tor-browser

all: build-all

build-all:
	@mkdir -p assets/appscripts
.for APP in ${APPS}
	@./update.sh "${APP}"
	@appscript -t -o ${PWD}/assets/appscripts/${APP}.appscript ${APP}
.endfor

build:
	@mkdir -p assets/appscripts
	@./update.sh "${APP}"
	@appscript -t -o ${PWD}/assets/appscripts/${APP}.appscript ${APP}

update:
.for APP in ${APPS}
	@./update.sh ${APP}
.endfor
