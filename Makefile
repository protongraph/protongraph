CHECK_FILES+=

DOC_FILES+=	README.md

PKGNAME?=	protongraph
VERSION?=	0.0.1

# Jenkins CI integration
BUILD_NUMBER ?= 1

# Skip copyright check in the following paths
MKL_COPYRIGHT_SKIP?=^(tests|packaging)

OUTPUT= main
GODOT_BINARY= godot.osx.3.4.2-stable.tools.64

define RUN_CMAKE
	echo $(1) && mkdir $(1)/build && cd $(1)/build && cmake .. && cd -
endef

.PHONY:

all: mklove-check compile godot_export package

include mklove/Makefile.base

# nb. this is currently specific to osx. Ideally we should be able to package for linux and windows as well.
package:
	mkdir -p bin/protongraph.app/Contents/MacOS/ || echo "build directory already exists"
	rm -r bin/protongraph.app/Contents/MacOS/secrets || echo "kafka secrets not found"
	cp -rf builds/osx/protongraph.app bin
	cp bin/$(OUTPUT) bin/protongraph.app/Contents/MacOS/
	cp config/kafka.config bin/protongraph.app/Contents/MacOS/config || echo "kafka config not found"
	cp -rf config/secrets bin/protongraph.app/Contents/MacOS/config || echo "kafka secrets not found"
	cp native/thirdparty/librdkafka/bin/osx/librdkafka.1.dylib bin/protongraph.app/Contents/MacOS/
	cp native/thirdparty/librdkafka/bin/osx/librdkafka.dylib bin/protongraph.app/Contents/MacOS/
	cp native/thirdparty/mesh_optimizer/bin/osx/libmeshoptimizer.dylib bin/protongraph.app/Contents/MacOS/
	install_name_tool -change /usr/local/lib/librdkafka.1.dylib @executable_path/librdkafka.1.dylib bin/protongraph.app/Contents/MacOS/$(OUTPUT)
	install_name_tool -change /usr/local/lib/libmeshoptimizer.dylib @executable_path/libmeshoptimizer.dylib bin/protongraph.app/Contents/MacOS/$(OUTPUT)

# Note that this does not work properly for Godot 3.4.2-stable, possibly due to reasons related to https://github.com/godotengine/godot/issues/44403.
# Also evidently this is currently specific to osx, one presumably would want to generalise this to windows and linux as well.
godot_export:
	./$(GODOT_BINARY) --path . --export "osx" "bin/$(OUTPUT)"

compile:
	pushd native; ./compile_all.sh osx release; popd
