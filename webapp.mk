VERSION = ${shell cat VERSION}
BUILD_NUMBER = ${shell cat BUILD_NUMBER}

OPTIMIZER = node ./src/main/javascript/r.js -o

COFFEE_SRC = ./src/main/coffeescript/www/

UNOPTIMIZED_DIR = ./build/www-unoptimized/
OPTIMIZED_DIR = ./build/www/
IOS_WWW_DIR = ./ios/www/

APP_BUILD = ${UNOPTIMIZED_DIR}js/app.build.js

webapp: webapp_paths webapp_base webapp_version webapp_coffee webapp_requirejs

webapp_paths:
	@echo ""
	@echo "## WEBAPP PATHS ##"

	mkdir -p ${OPTIMIZED_DIR}
	mkdir -p ${UNOPTIMIZED_DIR}

webapp_base:
	@echo ""
	@echo "## WEBAPP COPY BASE FILES ##"
	cp -r ./src/main/webapp/www/* ${UNOPTIMIZED_DIR}
	touch ${UNOPTIMIZED_DIR}/cordova.js

webapp_version:
	@echo ""
	@echo "## WEBAPP SETTING VERSION ##"
	@echo "Version: ${VERSION}"
	@echo "Build number: ${BUILD_NUMBER}"
	sed -i "" 's/$${project.version}/${VERSION}/g' ${UNOPTIMIZED_DIR}/index.html
	sed -i "" 's/$${env.BUILD_NUMBER}/${BUILD_NUMBER}/g' ${UNOPTIMIZED_DIR}/index.html

webapp_coffee:
	@echo ""
	@echo "## WEBAPP COFFEESCRIPT COMPILE ##"

	coffee -o ${UNOPTIMIZED_DIR} -c ${COFFEE_SRC}

webapp_watch_coffee:
	@echo ""
	@echo "## WEBAPP COFFEESCRIPT COMPILE + WATCH ##"

	coffee -m -o ${UNOPTIMIZED_DIR} -c -w ${COFFEE_SRC}

webapp_requirejs:
	@echo ""
	@echo "## WEBAPP REQUIRE-JS OPTIMIZE ##"
    # overwrite APP_BUILD file's 'dir' parameter
	${OPTIMIZER} ${APP_BUILD} dir=${OPTIMIZED_DIR}

copy_www_to_ios:
	@echo ""
	@echo "## WEBAPP COPYING OPTIMIZED WWW TO IOS FOLDER ##"
	if test -d ${IOS_WWW_DIR}; then rm -r ${IOS_WWW_DIR}; fi
	cp -r ${OPTIMIZED_DIR} ${IOS_WWW_DIR}
    
