### Example payload for fence.tpgn

```
{
	command:build, 
	inputs: [{
		node: [{
			data: {
				points: [
					{ in:[0, 0, 0], out:[0, 0, 0], pos:[-4.35923, 0, -3.58755], tilt:0 }, 
					{ in:[-3.83067, -0.005032, -0.890189], out:[3.83067, 0.005032, 0.890189], pos:[1.26936, 0.002264, -4.18087], tilt:0 }, 
					{ in:[0.210581, 0, -1.57824], out:[-0.210581, 0, 1.57824], pos:[5.66448, 0, 1.26848], tilt:0 },
					{ in:[0, 0, 0], out:[0, 0, 0], pos:[4.15667, 0, 4.50781], tilt:0 }
				], 
				transform: {
					basis:[[1, 0, 0], [0, 1, 0], [0, 0, 1]], 
					pos:[0, 0, 0]
				}
			}, 
			name:Path,
			node_path_input:{Path:/root/EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@629/@@630/@@639/@@640/@@6275/@@6109/@@6110/@@6111/@@6112/@@6113/TestProtongraph/Fence/Inputs/Path}
			type:curve_3d
		},
		{
			children:[{
				children:[{
					data:{
						mesh:{
							0:[[[ ... ]], Null, Null, Null, [ ... ]] /// (see below)
						},
						resource_path:res://assets/fences/models/fence_planks.glb::2,
						transform:{
							basis:[[1, 0, 0], [0, 1, 0], [0, 0, 1]],
							pos:[0, -0.05, 0]
						}
					},
					name:fence_planks,
					node_path_input:{fence_planks:/root/EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@629/@@630/@@639/@@640/@@6275/@@6109/@@6110/@@6111/@@6112/@@6113/TestProtongraph/Fence/Inputs/fence_planks/tmpParent/fence_planks}
					type:mesh
				}],
				data: {
					transform: {
						basis:[[1, 0, 0], [0, 1, 0], [0, 0, 1]], pos:[0, 0, 0]
					}
				},
				name:tmpParent,
				node_path_input:{tmpParent:/root/EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@629/@@630/@@639/@@640/@@6275/@@6109/@@6110/@@6111/@@6112/@@6113/TestProtongraph/Fence/Inputs/fence_planks/tmpParent}
				type:node_3d
			}],
			data: {
				transform: {
					basis:[[1, 0, 0], [0, 1, 0], [0, 0, 1]], pos:[0, 0, 0]
				}
			},
			name:fence_planks,
			node_path_input:{fence_planks:/root/EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@629/@@630/@@639/@@640/@@6275/@@6109/@@6110/@@6111/@@6112/@@6113/TestProtongraph/Fence/Inputs/fence_planks}
			type:node_3d
		}], 
		resources:[{
			name:Path, 
			node_path_input:{
				Path:/root/EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@629/@@630/@@639/@@640/@@6275/@@6109/@@6110/@@6111/@@6112/@@6113/TestProtongraph/Fence/Inputs/Path
			}
		}, 
		{
			children:[{
				children:[{
					name:fence_planks, 
					node_path_input:{
						fence_planks:/root/EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@629/@@630/@@639/@@640/@@6275/@@6109/@@6110/@@6111/@@6112/@@6113/TestProtongraph/Fence/Inputs/fence_planks/tmpParent/fence_planks
					}
				}],
				name:tmpParent,
				node_path_input:{
					tmpParent:/root/EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@629/@@630/@@639/@@640/@@6275/@@6109/@@6110/@@6111/@@6112/@@6113/TestProtongraph/Fence/Inputs/fence_planks/tmpParent
				}
			}],
			name:fence_planks,
			node_path_input:{
				fence_planks:/root/EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@629/@@630/@@639/@@640/@@6275/@@6109/@@6110/@@6111/@@6112/@@6113/TestProtongraph/Fence/Inputs/fence_planks
			}
		}]
	}],
	inspector:[],
	tpgn:{
		"connections": [
			{
				"from": "GraphNode3",
				"from_port": 0,
				"to": "GraphNode6",
				"to_port": 0
			},
			{
				"from": "GraphNode7",
				"from_port": 0,
				"to": "GraphNode6",
				"to_port": 1
			},
			{
				"from": "GraphNode6",
				"from_port": 0,
				"to": "GraphNode5",
				"to_port": 1
			},
			{
				"from": "remote_input_curve_3d",
				"from_port": 0,
				"to": "GraphNode3",
				"to_port": 0
			},
			{
				"from": "remote_input_3d2",
				"from_port": 0,
				"to": "GraphNode5",
				"to_port": 0
			},
			{
				"from": "remote_input_3d_reference",
				"from_port": 0,
				"to": "remote_sync_and_post",
				"to_port": 0
			},
			{
				"from": "GraphNode5",
				"from_port": 0,
				"to": "remote_sync_and_post",
				"to_port": 1
			}
		],
		"editor": {
			"offset_x": -676.35968,
			"offset_y": -447.364838
		},
		"inspector": {},
		"nodes": [
			{
				"data": {},
				"editor": {
					"inputs": {},
					"offset_x": 120,
					"offset_y": -160
				},
				"name": "GraphNode5",
				"type": "duplicate_nodes"
			},
			{
				"data": {},
				"editor": {
					"inputs": {
						"0": {
							"value": 0
						},
						"1": {
							"value": 90
						},
						"2": {
							"value": 0
						}
					},
					"offset_x": -400,
					"offset_y": 160
				},
				"name": "GraphNode7",
				"type": "value_vector3"
			},
			{
				"data": {},
				"editor": {
					"inputs": {
						"1": {
							"value": 1.086
						},
						"2": {
							"value": 0
						},
						"3": {
							"value": 1
						},
						"4": {
							"value": true
						}
					},
					"offset_x": -400,
					"offset_y": -60
				},
				"name": "GraphNode3",
				"type": "curve_sample_points_constant"
			},
			{
				"data": {},
				"editor": {
					"inputs": {
						"0": {
							"value": "Path"
						},
						"1": {
							"value": false
						}
					},
					"offset_x": -780,
					"offset_y": -40
				},
				"name": "remote_input_curve_3d",
				"type": "remote_input_curve_3d"
			},
			{
				"data": {},
				"editor": {
					"inputs": {
						"0": {
							"value": "fence_planks"
						},
						"1": {
							"value": false
						}
					},
					"offset_x": 100,
					"offset_y": -420
				},
				"name": "remote_input_3d_reference",
				"type": "remote_input_3d_reference"
			},
			{
				"data": {},
				"editor": {
					"inputs": {
						"0": {
							"value": "fence_planks"
						},
						"1": {
							"value": false
						}
					},
					"offset_x": -200,
					"offset_y": -240
				},
				"name": "remote_input_3d2",
				"type": "remote_input_3d"
			},
			{
				"data": {},
				"editor": {
					"inputs": {},
					"offset_x": 580,
					"offset_y": -220
				},
				"name": "remote_sync_and_post",
				"type": "remote_sync_and_post"
			},
			{
				"data": {},
				"editor": {
					"inputs": {
						"1": {
							"value": "(0, 0, 0)"
						},
						"2": {
							"value": true
						}
					},
					"offset_x": -120,
					"offset_y": -80
				},
				"name": "GraphNode6",
				"type": "rotate_transforms_offset"
			}
		]
	}
}
```

Where 0:[[[ ... ]], []] takes the form of an array of points, where each point is an array of 3 floats, tupled with a list of numbers,
as well as several optional values.
