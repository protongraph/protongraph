CHECK_FILES+=

DOC_FILES+=	README.md

PKGNAME?=	protongraph
VERSION?=	0.0.1

# Jenkins CI integration
BUILD_NUMBER ?= 1

# Skip copyright check in the following paths
MKL_COPYRIGHT_SKIP?=^(tests|packaging)

OUTPUT= ProtonGraph
OUTPUT_DMG= builds/osx/release.dmg
GODOT_BINARY= godot.osx.3.4.2-stable.tools.64

define RUN_CMAKE
	echo $(1) && mkdir $(1)/build && cd $(1)/build && cmake .. && cd -
endef

.PHONY:

all: mklove-check compile copy_compiled_files godot_export package

post_compile: mklove-check copy_compiled_files godot_export package

include mklove/Makefile.base

# nb. this is currently specific to osx. Ideally we should be able to package for linux and windows as well.
package:
	mkdir -p bin/protongraph.app/Contents/MacOS/ || echo "build directory already exists"
	mkdir -p bin/ProtonGraph.app/Contents/MacOS/config/secrets || echo "secrets directory already exists"
	rm -r bin/protongraph.app/Contents/MacOS/config/secrets || echo "kafka secrets not found"
	cp -rf builds/osx/protongraph.app bin
	cp config/kafka.config bin/protongraph.app/Contents/MacOS/config || echo "kafka config not found"
	cp -rf config/secrets bin/protongraph.app/Contents/MacOS/config || echo "kafka secrets not found"
	cp build/launch bin/protongraph.app/Contents/MacOS/
	cp native/thirdparty/librdkafka/librdkafka.gdns bin/ProtonGraph.app/Contents/MacOS/librdkafka.gdns
	cp native/thirdparty/librdkafka/librdkafka.tres bin/ProtonGraph.app/Contents/MacOS/librdkafka.tres
	cp native/thirdparty/librdkafka/bin/osx/librdkafka.1.dylib bin/protongraph.app/Contents/MacOS/
	cp native/thirdparty/librdkafka/bin/osx/librdkafka.dylib bin/protongraph.app/Contents/MacOS/
	cp native/thirdparty/mesh_optimizer/bin/osx/libmeshoptimizer.dylib bin/protongraph.app/Contents/MacOS/

# Evidently this is currently specific to osx, one presumably would want to generalise this to windows and linux as well.
godot_export:
	./$(GODOT_BINARY) --path . --no-window --quiet --export "osx"
	./extract_app.sh

compile:
	pushd native; ./compile_all.sh osx release; popd

copy_compiled_files:
	cp native/thirdparty/librdkafka/librdkafka.gdns librdkafka.gdns
	cp native/thirdparty/librdkafka/librdkafka.tres librdkafka.tres
	cp native/thirdparty/librdkafka/bin/osx/librdkafka.dylib librdkafka.dylib
	cp native/thirdparty/librdkafka/bin/osx/librdkafka.1.dylib librdkafka.1.dylib
