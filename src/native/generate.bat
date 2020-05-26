cd godot-cpp
scons platform=windows generate_bindings=yes -j8 bits=64
scons platform=linux generate_bindings=yes -j8 bits=64
scons platform=osx generate_bindings=yes -j8 bits=64
cd ..
scons platform=windows bits=64
scons platform=linux bits=64
scons platform=osx bits=64
