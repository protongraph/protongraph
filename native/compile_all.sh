#!/bin/bash

platform=$1

cd godot-cpp
scons -j2 bits=64 generate_bindings=yes debug_symbols=no platform=$platform target=release

cd ../thirdparty/mesh_optimizer
mkdir -p bin
scons -j2 platform=$platform bits=64 debug_symbols=no target=release

