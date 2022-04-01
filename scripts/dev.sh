#!/bin/bash

if [ $1 == "stop" ]; then
  processId=$(ps | grep "./godot\.osx" | awk '{print $1}')
  kill -9 $processId
fi

if [ $1 == "start" ]; then
  ./godot.osx.3.4.2-stable.tools.64
fi