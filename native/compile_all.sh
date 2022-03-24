#!/bin/bash

platform=$1
target=0
threads=0


if [ -z "$2" ]
  then
    target="release"
  else
    target=$2
fi

if [ -z "$3" ]
  then
    threads=2
  else
    threads=$3
fi


# Compile the gdnative bindings
cd godot-cpp
scons -j${threads} bits=64 generate_bindings=yes debug_symbols=no platform=$platform target=$target

# Add kafka client support so that we can consume and produce to kafka topics on a (secured) kafka cluster or vm.
cd ../thirdparty/librdkafka
scons -j${threads} platform=$platform bits=64 debug_symbols=no target=$target
# We'll need to repoint a dependency within the dynamic library to point to the relative path to wherever we are
# executing the project.  At present I have set this relative to the root.  When eventually this is compiled to an
# osx bundle we'll need to change this to be relative to the root of the bundle.
if [ ${1} == "osx" ]
  then
    cp lib/src/librdkafka.1.dylib bin/osx/librdkafka.1.dylib
    install_name_tool -change /usr/local/lib/librdkafka.1.dylib @executable_path/native/thirdparty/librdkafka/bin/osx/librdkafka.1.dylib bin/osx/librdkafka.dylib
fi

if [ ${1} == "linux" ]
  then
    cp lib/src/librdkafka.so.1 bin/x11/librdkafka.so.1
    patchelf --set-rpath '$ORIGIN' bin/x11/librdkafka.so
fi

# Make sure that we add the mesh optimizer.  nb, not sure that this is required any more? https://github.com/godotengine/godot/pull/47764 , https://github.com/protongraph/protongraph/issues/101
cd ../mesh_optimizer
scons -j${threads} platform=$platform bits=64 debug_symbols=no target=$target

