#!/bin/bash

platform=$1

cd godot-cpp/godot_headers
scons -j2 bits=64 generate_bindings=yes debug_symbols=no platform=$platform

cd ../
scons -j2 platform=$platform bits=64 debug_symbols=no

cd ../thirdparty/mesh_optimizer
scons -j2 platform=$platform bits=64 debug_symbols=no

