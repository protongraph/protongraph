#ifndef MESH_OPTIMIZER_H
#define MESH_OPTIMIZER_H

#include <Godot.hpp>
#include <Sprite.hpp>
#include <Node.hpp>
#include <MeshInstance.hpp>
#include <Transform.hpp>
#include <NodePath.hpp>
#include <Mesh.hpp>
#include <Skin.hpp>
#include <ArrayMesh.hpp>

namespace godot {

struct MeshInfo {
    Transform transform;
    Ref<Mesh> mesh;
    String name;
    Node *original_node;
    NodePath skeleton_path;
    Ref<Skin> skin;
};

class MeshOptimizer : public Reference {
    GODOT_CLASS(MeshOptimizer, Reference);
	void _find_all_mesh_instances(Array r_items, Node *p_current_node, const Node *p_owner);
	void _dialog_action(String p_file);

public:
    void _init();
    static void _register_methods();  

	void optimize(const String p_file, Node *p_root_node, float p_threshold = 1.0f);
    Ref<ArrayMesh> optimize_mesh(Ref<Mesh> p_mesh, float p_threshold = 1.0f, bool p_sloppy = false);
    MeshInstance *optimize_mesh_instance(Ref<Mesh> p_mesh, float p_threshold, NodePath p_skeleton_path, String p_name, Ref<Skin> p_skin, bool p_sloppy = false);
	void simplify(Node *p_root_node, float p_threshold = 1.0f);
     MeshOptimizer();
    ~MeshOptimizer();
};

}

#endif