#!/bin/bash

if [ $1 == "stop" ]; then
  processId=$(ps | grep "./godot\.osx" | cut -d " " -f2)
  kill -9 $processId
  processId=$(ps | grep "./godot\.osx" | cut -d " " -f1)
  kill -9 $processId
fi

if [ $1 == "start" ]; then
  ./godot.osx.3.4.2-stable.tools.64
fi