#!/bin/bash
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
GODOT_EXPORT_TO_HEADLESS_BINARY= godot.osx.3.4.3-stable.tools.server.64
DOCKER_EXPORT_TO_HEADLESS_BINARY= godot.linux.3.4.2-stable.headless.64

LIBRDKAFKA_DIR= native/thirdparty/librdkafka/lib

define RUN_CMAKE
	echo $(1) && mkdir $(1)/build && cd $(1)/build && cmake .. && cd -
endef

.PHONY:

# Build within docker container for separate docker process
all: mklove-check build_rdkafka compile_linux docker_export_linux
# Build on osx for osx
osx: mklove-check build_rdkafka compile_osx godot_export_osx package_osx
# Build on osx for docker process
docker: mklove-check build_rdkafka compile_linux godot_export_linux package_docker

include mklove/Makefile.base

build_rdkafka:
	pushd $(LIBRDKAFKA_DIR); ./configure && make; popd

# nb. this is currently specific to osx. Ideally we should be able to package for linux and windows as well.
package_osx:
	mkdir -p bin/protongraph.app/Contents/MacOS/ || echo "build directory already exists"
	mkdir -p bin/ProtonGraph.app/Contents/MacOS/config/secrets || echo "secrets directory already exists"
	rm -r bin/protongraph.app/Contents/MacOS/config/secrets || echo "kafka secrets not found"
	cp -rf builds/osx/protongraph.app bin
	cp config/kafka.config bin/protongraph.app/Contents/MacOS/config || echo "kafka config not found"
	cp -rf config/secrets bin/protongraph.app/Contents/MacOS/config || echo "kafka secrets not found"
	cp build/launch bin/protongraph.app/Contents/MacOS/
	cp native/thirdparty/librdkafka/librdkafka.gdns bin/ProtonGraph.app/Contents/MacOS/librdkafka.gdns
	cp native/thirdparty/librdkafka/librdkafka.tres bin/ProtonGraph.app/Contents/MacOS/librdkafka.tres
	cp build/Info.plist bin/protongraph.app/Contents/Info.plist
	cp native/thirdparty/librdkafka/bin/osx/librdkafka.1.dylib bin/protongraph.app/Contents/MacOS/
	cp native/thirdparty/librdkafka/bin/osx/librdkafka.dylib bin/protongraph.app/Contents/MacOS/
	cp native/thirdparty/mesh_optimizer/bin/osx/libmeshoptimizer.dylib bin/protongraph.app/Contents/MacOS/

package_docker:
	docker build . -t protongraph
# Evidently this is currently specific to osx, one presumably would want to generalise this to windows and linux as well.
godot_export_osx:
	./$(GODOT_BINARY) --path . --no-window --quiet --export "osx"
	./extract_app.sh

# Nb, this presupposes that you are exporting in server-mode (headless) to linux from a custom build of godot (built off tag 3.4.3-stable).
# To obtain said custom build, you need to run the following commands:
# #godot> git checkout 3.4.3-stable
# #godot> scons platform=server tools=yes target=release_debug --jobs=$(sysctl -n hw.logicalcpu)
# #godot> cp bin/godot_server.osx.opt.tools.64 /<PATH_TO_PROTONGRAPH_ON_YOUR_MACHINE>/protongraph/godot.osx.3.4.3-stable.tools.server.64
godot_export_linux:
	pushd ~/.local/share/godot/templates/3.4.3.stable; ln -s ~/Library/Application Support/Godot/templates/3.4.3.stable; popd
	cp native/thirdparty/librdkafka/bin/x11/librdkafka.so ./
	cp native/thirdparty/mesh_optimizer/bin/x11/libmeshoptimizer.so ./
	./$(GODOT_EXPORT_TO_HEADLESS_BINARY) --path . --no-window --display-driver headless --quiet --export "server"
	mv headless builds/server
	mv headless.pck builds/server

docker_export_linux:
	cp native/thirdparty/librdkafka/bin/x11/librdkafka.so ./
	cp native/thirdparty/librdkafka/bin/x11/librdkafka.so.1 ./
	cp native/thirdparty/mesh_optimizer/bin/x11/libmeshoptimizer.so ./
	cp native/thirdparty/librdkafka/librdkafka.gdns librdkafka.gdns
	cp native/thirdparty/librdkafka/librdkafka.tres librdkafka.prod.tres
	./$(DOCKER_EXPORT_TO_HEADLESS_BINARY) --path . --no-window --display-driver headless --quiet --export "server"
	mv headless builds/server
	mv headless.pck builds/server

compile_osx:
	pushd native; ./compile_all.sh osx release; popd

compile_linux:
	pushd native; ./compile_all.sh linux release; popd
