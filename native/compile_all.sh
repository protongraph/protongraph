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



cd godot-cpp
scons -j${threads} bits=64 generate_bindings=yes debug_symbols=no platform=$platform target=$target

cd ../thirdparty/mesh_optimizer
scons -j${threads} platform=$platform bits=64 debug_symbols=no target=$target

