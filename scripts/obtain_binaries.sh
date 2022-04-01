#!/bin/bash

# Check if godot.osx.3.4.2-stable.tools.64 exists.
if [ ! -f "./godot.osx.3.4.2-stable.tools.64" ]; then
  echo "godot.osx.3.4.2-stable.tools.64 does not exist.  Obtaining binary."
  curl -sS https://downloads.tuxfamily.org/godotengine/3.4.2/Godot_v3.4.2-stable_osx.universal.zip > osx.zip
  unzip -o osx.zip -d dev
  cp ./dev/Godot.app/Contents/MacOS/Godot godot.osx.3.4.2-stable.tools.64
  rm osx.zip
fi

# Check if godot.linux.3.4.2-stable.headless.64 exists.
if [ ! -f "./godot.linux.3.4.2-stable.headless.64" ]; then
  echo "godot.linux.3.4.2-stable.headless.64 does not exist.  Obtaining binary."
  curl -sS https://downloads.tuxfamily.org/godotengine/3.4.2/Godot_v3.4.2-stable_linux_headless.64.zip > linux.zip
  unzip -o linux.zip -d dev
  cp ./dev/Godot_v3.4.2-stable_linux_headless.64 godot.linux.3.4.2-stable.headless.64
  rm linux.zip
fi
