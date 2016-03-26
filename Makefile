# Stylecheck disabled in 'all' target, until coffee-lint is installed on milou
# all: stylecheck build deploy_structure
include webapp.mk


all: build deploy_structure

#webapp: webapp

build: webapp cordova
debug: webapp cordova_debug

update: webapp cordova_update
update_debug: webapp cordova_update_debug

clean:
	@echo ""
	@echo "## CLEAN ##"
	find ./ -name \*.*~ -exec rm {} \;
	rm -f *.build_tmp	
	rm -Rf ./build

#include stylecheck.mk
#include cordova.mk
#include deploy.mk