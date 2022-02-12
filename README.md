# ProtonGraph

**Work in progress, please read the Current Status section**

A node based tool for procedural content creation.
Which means, you have a collection of nodes that you connect together to
create a complex result. You can see it as a form of visual scripting, but
for 3D models generation.

![image](https://user-images.githubusercontent.com/52043844/99144382-b0852400-2665-11eb-9ca1-2e8ddb34fc93.png)

## Current Status

ProtonGraph is currently going through **a lot of refactoring** and a rebrand. As a result, **it's not usable
right now**, but the next major update is due soon and will break backward compatiblity. Therefore I suggest
you to wait until it's released. 
Release announcement will be made here and on the social media listed below.

### Rebrand
ProtonGraph used to be called ConceptGraph, but I noticed Microsoft already have a product called like
this, they also own the domain name and possibly the trademark too. So we rebranded the tool as ProtonGraph
after running a community poll. This way we get a unique name (as in, not in used by anybody else) and
a valid domain name and you won't mix it up with conceptual graphs which are completely different things.


## Roadmap

ProtonGraph is a standalone software but it's a lot more convienient to drive the content generation from
you engine of choice. So the immediate priority is to get a sync plugin running for the Godot engine as 
a proof of concept. 

Why? Because this requires internal changes that may or may not break compatibility so it has to be done
as soon as possible. Once the software works as expected, we need to write massive amounts of documentation
on how to actually use the software, tutorials and example files.

+ To track the work in progress and planned features, [head over the project board](https://github.com/proton-graph/proton-graph/projects)


## Build from source

### Read me first

If you want to build the project from source yourself, first read the instructions on this repository: https://github.com/proton-graph/environment.  Note: Originally Protongraph required a custom build of the Godot game engine, but this is no longer required as of Godot 3.4.x.  You will still need to build the engine from source though if you want to compile from command line, see [here](https://docs.godotengine.org/en/stable/development/compiling/index.html) for a guide on how to do this.

(Note that as of writing Protongraph supports building for Godot 3.4.2, and work to migrate Protongraph to Godot 4 is currently in progress.)

Once you have a built Godot binary you'll want to move it to the root of the Protongraph directory.  Currently the project Makefile assumes that this binary will be labelled `godot.osx.3.4.2-stable.tools.64`.  Note that `make` will not work unless you have this binary available.

You'll also want the export templates for 3.4.2 as well, you can find them [here](https://downloads.tuxfamily.org/godotengine/3.4.2/).  These templates should be placed in the build folder.

Downloading a built version of the Godot binary will not work as the officially compiled versions do not have tools enabled, you will need either to build from source yourself or source the file from an unofficial build repository.

### Making the project

Protongraph has two modes of operation being Default responder mode, and Kafka producer mode.  Default responder mode responds along the Websocket connection that sync-godot establishes with Protongraph via the Godot engine client.  In this mode, packets are sent back and forth directly between the Godot engine and Protongraph via Websocket.

In Kafka producer mode, Protongraph writes messages it receives via a Websocket connection to a Kafka topic instead.  This mode is useful for instance if Protongraph is deployed to the cloud, and there are up to several additional network hops between the running Godot game and Protongraph, eg Godot game -> Signalling server -> Kafka topic -> Kafka consumer -> Protongraph.  In this instance, the output work from Protongraph would return to the Godot game in potentially a 1 to many relationship via eg Protongraph -> Kafka topic -> Signalling server -> { set of networked clients running the Godot game }.

## Social medias

Despite being a very new project, the ConceptGraph community is growing. Head over to the Discord server if you want to ask for help
and hear about every little update or work in progress. Head over to Youtube or LBRY to access video tutorials.

+ **Discord server:** https://discord.gg/utUtB5r
+ **Twitter:** https://twitter.com/HungryProton
+ **Youtube:** https://www.youtube.com/channel/UCN-YuzlFmOOh0A5iwiDab2w
+ **LBRY:** https://lbry.tv/@HungryProton:2


## Licence
+ Unless stated otherwise, this project is available under the MIT licence.
+ Thirdparties library have their own licence but are all MIT friendly.
+ [The unofficial Godot logo redesign](https://marek95.github.io/godot.html)
featured on the splash screen is from marek95 and is used with permission.
