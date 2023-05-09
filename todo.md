# TODO

## Core
+ Detect (and prevent) loops in the graph
+ Enforce data validity from the slot options
	- This currently only applies to the built-in component ui, but it does
	not check the validity of what's provided by connected nodes.
+ Track down orphan nodes

## UI
+ Collapse nodes (to save space)
+ Different slot icons
+ implicit conversions (float -> vector)
+ Pin variable tooltip? Default and min / max values in the graph inspector?
+ Dropping a node on a (valid) connection auto connects it
+ Save viewport camera position
+ Visibility toggle on the 3D viewport tree
+ Nested graphs
+ Add per view UndoRedo support
+ Keyboard shortcuts in the add node popup
+ Split the node UI in groups. (store the info in the slot options)
	- add the ability to expand / fold a group
+ Show total build times and per node info.

## Nodes
+ Port back all the nodes
+ Print as text
	- option to show individual array elements / group them
	- collapse individual elements
	- Show total array size
+ Expression node
+ Relax points
+ Stretch along curve
	- port back and do the suggested edits
+ Mesh operations
	- Displace
	- Auto smooth
	- Subdivide
	- Extrude
	- Bevel
+ Curve / Polyline operations:
	- Expand
	- Smooth
	- Bevel

## Plugins
+ Improve remote sync robustness
+ Port back Kafka support
