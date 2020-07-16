# Concept Graph

An addon for node based content creation directly from the Godot engine editor.

The graph node can be as simple ...
![image](https://user-images.githubusercontent.com/52043844/82753238-77f64300-9dc4-11ea-9526-f7ada2883abc.png)

... or as complicated as you want ![image](https://user-images.githubusercontent.com/52043844/82753149-d0791080-9dc3-11ea-8b76-035d7115ee55.png)

[Video example 1](https://streamable.com/1gke2)

[Video example 2](https://streamable.com/sh3dhr)

## Status

This addon is still a **work in progress**. Until it hits version 1.0, it is not
considered production ready and there's no guarantees the files generated with
this addon will be compatible with later versions.

## Quick start

[Check out the wiki](https://github.com/HungryProton/concept_graph/wiki) for detailled explainations

Check out the **examples folder** at the root of the addon folder for pre-made
templates and example scences.

Check out [this video tutorial](https://www.youtube.com/watch?v=hLFgfyKbPoU) for a step by step guide on how to create your first graph

### Known issues and roadmap

For a complete list of known issues, [head over there](https://github.com/HungryProton/concept_graph/issues)

#### Object was deleted while awaiting a callback
Go to your **Project Settings** under **Memory/Limits**, increase the message queue size to 4096 at least. If the issue appears again, increase this value even higher

#### General issues


+ Save files needs improvement to make them work with future versions.
+ Missing Undo/Redo support for some operations.
+ Overall performance needs to be improved.

#### Roadmap

1. Make it work
2. Make it user friendly
3. Make it fast

Right now my focus is on user experience and stability. I'm working on this tool
while also using it for my own game so I can actually see what's missing and
what part of the workflow could be improved for real world use.

+ **Future plans** include
  - More mesh operations
  - Heightmap tools
  - Automation
  - Execution flow control (conditionals and loops)

New ideas are welcome!
