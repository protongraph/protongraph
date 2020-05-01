# Concept Graph

An addon for node based content creation directly from the Godot engine editor.

The graph node can be as simple ![image](https://user-images.githubusercontent.com/52043844/75927366-850e3080-5e6c-11ea-8596-ea8e1450c9e2.png)

... or as complicated as you want ![image](https://user-images.githubusercontent.com/52043844/75927502-c69edb80-5e6c-11ea-9f40-21c1f9684786.png)

[Video example 1](https://streamable.com/1gke2)

[Video example 2](https://streamable.com/sh3dhr)

## Status

This addon is still a **work in progress**. Until it hits version 1.0, it is not
considered production ready and there's no guarantees the files generated with
this addon will be compatible with later versions.


### Known issues and roadmap

#### General issues
+ Save files needs improvement to make them work with future versions.
+ Missing Undo/Redo support
+ Search bar in the **Add node panel** doesn't work.
+ Overall performance could be improved.

#### Graph nodes issues
+ No **Output** node by default.
+ Duplicating graph nodes doesn't work.

#### Roadmap

1. Make it work
2. Make it user friendly
3. Make it fast

+ Right now my focus is on user experience and stability. I'm working on this tool
while also using it for my own game so I can actually see what's missing and
what part of the workflow could be improved for real world use.
+ New features will be added as I need them when the overall usability will be
good enough for most people.
+ Comment nodes, groups and other QoL features are planned.
+ At some point, I'd like to add some sort of control flow (conditional and loops)
but it likely won't be implemented anytime soon.

## How does it work?

There's two main components to this addon:
+ The **ConceptGraph** node that you add to your editor
+ The **Templates** that holds the node graphs

Templates are attached to the ConceptGraph nodes. They are saved to disk and can
be shared accross many different nodes, this way you can define the node graph
once and change the parameters on the individual nodes directly.


## Quick start

+ Create a **ConceptGraph** node in the editor tree. It will automatically add
two child nodes, Input and Output
+ Select the ConceptGraph node, a new button "Concept Graph Editor" will appear
on the bottom dock. Click it to access the editor.
+ Load or create a new template
+ You can now right click anywhere in this panel to bring up the Nodes panel.
Double click on one of them or click the create button to add a new node to the
graph
+ Add an **Output** node to get a result.

Check out the **examples folder** at the root of the addon folder for pre-made
templates and more explainations.

## Licence

+ Unless stated otherwise, everything in this repository is MIT licenced.
+ The textures and 3d models found in the assets folder come from https://kenney.nl/ under a CC0 licence.

