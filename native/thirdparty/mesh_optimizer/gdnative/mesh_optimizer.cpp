#include "mesh_optimizer.h"
#include "../lib/src/meshoptimizer.h"
#include <ArrayMesh.hpp>
#include <Material.hpp>
#include <PackedScene.hpp>
#include <ResourceSaver.hpp>
#include <SurfaceTool.hpp>
#include <VisualServer.hpp>
#include <string>
#include <vector>

using namespace godot;

void MeshOptimizer::_register_methods() {
  // register_method("optimize", &MeshOptimizer::optimize);
  // register_method("optimize_mesh", &MeshOptimizer::optimize_mesh);
  // register_method("optimize_mesh_instance", &MeshOptimizer::optimize_mesh_instance);
  // register_method("simplify", &MeshOptimizer::simplify);
}

MeshOptimizer::MeshOptimizer() {}

MeshOptimizer::~MeshOptimizer() {}

void MeshOptimizer::_init() {}

// void MeshOptimizer::optimize(const String p_file, Node *p_root_node,
//                             float p_threshold) {
//   Ref<PackedScene> scene;
//   scene.instance();
//   simplify(p_root_node, p_threshold);
//   scene->pack(p_root_node);
//   ResourceSaver::get_singleton()->save(p_file, scene);
// }

// void MeshOptimizer::simplify(Node *p_root_node, float p_threshold) {
//   Array mesh_items;
//   _find_all_mesh_instances(mesh_items, p_root_node, p_root_node);
//
//   if (!mesh_items.size()) {
//     return;
//   }
//
//   std::vector<MeshInfo> meshes;
//   for (int32_t i = 0; i < mesh_items.size(); i++) {
//     MeshInfo mesh_info;
//     MeshInstance *mi = mesh_items[i];
//     Ref<Mesh> mesh = mi->get_mesh();
//     mesh_info.mesh = mesh;
//     mesh_info.transform = mi->get_transform();
//     mesh_info.name = mi->get_name();
//     mesh_info.original_node = mi;
//     mesh_info.skin = mi->get_skin();
//     mesh_info.skeleton_path = mi->get_skeleton_path();
//     meshes.push_back(mesh_info);
//   }
//
//   for (int32_t i = 0; i < meshes.size(); i++) {
//     MeshInfo mesh_info = meshes[i];
//     MeshInstance *mi = optimize_mesh_instance(mesh_info.mesh, p_threshold, mesh_info.skeleton_path, mesh_info.name, mesh_info.skin);
//     if (mesh_info.original_node) {
//       Spatial *spatial = Object::cast_to<Spatial>(mesh_info.original_node);
//       if (spatial) {
//         mi->set_transform(spatial->get_transform());
//       }
//       if (spatial->get_parent()) {
//         spatial->get_parent()->add_child(mi);
//         mi->set_owner(spatial->get_owner());
//       } else {
//         spatial->add_child(mi);
//         mi->set_owner(spatial->get_owner());
//       }
//     }
//     Spatial *spatial = Spatial::_new();
//     Spatial *mesh_instance = Object::cast_to<Spatial>(mesh_info.original_node);
//     if (mesh_instance) {
//       spatial->set_transform(mesh_instance->get_transform());
//       spatial->set_name(mesh_instance->get_name());
//     }
//     mesh_info.original_node->replace_by(spatial);
//   }
// }

// MeshInstance *MeshOptimizer::optimize_mesh_instance(Ref<Mesh> p_mesh, float p_threshold, NodePath p_skeleton_path, String p_name, Ref<Skin> p_skin, bool p_sloppy) {
//   Ref<ArrayMesh> result_mesh = optimize_mesh(p_mesh, p_threshold, p_sloppy);
//   MeshInstance *mi = MeshInstance::_new();
//   mi->set_mesh(result_mesh);
//   mi->set_skeleton_path(p_skeleton_path);
//   mi->set_name(p_name);
//   mi->set_skin(p_skin);
//   return mi;
// }

// Ref<ArrayMesh> MeshOptimizer::optimize_mesh(Ref<Mesh> p_mesh, float p_threshold, bool p_sloppy) {
//       struct Vertex {
//       float px, py, pz;
//       float nx, ny, nz;
//       float tx, ty, tz, tw;
//     };
//     // Vector<Ref<Mesh> > lod_meshes;
//     Array lod_meshes;
//     Ref<Mesh> mesh = p_mesh;
//     Ref<ArrayMesh> result_mesh;
//     result_mesh.instance();
//     Ref<ArrayMesh> orig_mesh = mesh;
//     if (mesh->is_class("ArrayMesh")) {
//       for (int32_t blend_i = 0; blend_i < orig_mesh->get_blend_shape_count();
//            blend_i++) {
//         String name = orig_mesh->get_blend_shape_name(blend_i);
//         result_mesh->add_blend_shape(name);
//       }
//     }
//     for (int32_t j = 0; j < mesh->get_surface_count(); j++) {
//       Ref<SurfaceTool> st;
//       st.instance();
//       st->begin(Mesh::PRIMITIVE_TRIANGLES);
//       st->create_from(mesh, j);
//       st->index();
//       const Array mesh_array = st->commit_to_arrays();
//       // Vector<Vector3> vertexes = mesh_array[Mesh::ARRAY_VERTEX];
//       Array vertexes = mesh_array[Mesh::ARRAY_VERTEX];
//       // https://github.com/zeux/meshoptimizer/blob/bce99a4bfdc7bbc72479e1d71c4083329d306347/demo/main.cpp#L414
//       // generate LOD levels, with each subsequent LOD using 70% triangles
//       // note that each LOD uses the same (shared) vertex buffer
//       std::vector<std::vector<uint32_t>> lods;
//       lods.resize(2);
//       std::vector<uint32_t> unsigned_indices;
//       {
//         // Vector<int32_t> indices = mesh_array[Mesh::ARRAY_INDEX];
//         Array indices = mesh_array[Mesh::ARRAY_INDEX];
//         unsigned_indices.resize(indices.size());
//         for (int32_t o = 0; o < indices.size(); o++) {
//           unsigned_indices[o] = indices[o];
//         }
//       }
//       lods[0] = unsigned_indices;
//       std::vector<Vertex> meshopt_vertices;
//       meshopt_vertices.resize(vertexes.size());
//       // Vector<Vector3> normals = mesh_array[Mesh::ARRAY_NORMAL];
//       // Vector<real_t> tangents = mesh_array[Mesh::ARRAY_TANGENT];
//       Array normals = mesh_array[Mesh::ARRAY_NORMAL];
//       Array tangents = mesh_array[Mesh::ARRAY_TANGENT];
//       for (int32_t k = 0; k < vertexes.size(); k++) {
//         Vertex meshopt_vertex;
//         Vector3 vertex = vertexes[k];
//         meshopt_vertex.px = vertex.x;
//         meshopt_vertex.py = vertex.y;
//         meshopt_vertex.pz = vertex.z;
//         if (normals.size()) {
//           Vector3 normal = normals[k];
//           meshopt_vertex.nx = normal.x;
//           meshopt_vertex.ny = normal.y;
//           meshopt_vertex.nz = normal.z;
//         }
//         if (tangents.size()) {
//           meshopt_vertex.tx = tangents[k * 4 + 0];
//           meshopt_vertex.ty = tangents[k * 4 + 1];
//           meshopt_vertex.tz = tangents[k * 4 + 2];
//           meshopt_vertex.tw = tangents[k * 4 + 3];
//         }
//         meshopt_vertices[k] = meshopt_vertex;
//       }
//
//       // simplifying from the base level sometimes produces better results
//
//       const int32_t current_lod = lods.size() - 1;
//
//       std::vector<uint32_t> lod;
//
//       float threshold = p_threshold;
//       int32_t target_index_count =
//           (unsigned_indices.size() * threshold) / 3 * 3;
//       float target_error = 1e-3f;
//
//       if (unsigned_indices.size() < target_index_count) {
//         target_index_count = unsigned_indices.size();
//       }
//
//       lod.resize(unsigned_indices.size());
//       if(!p_sloppy) {
//         lod.resize(meshopt_simplify(
//             lod.data(), unsigned_indices.data(), unsigned_indices.size(),
//             &meshopt_vertices.data()[0].px, meshopt_vertices.size(),
//             sizeof(Vertex), target_index_count, target_error));
//       } else {
//         lod.resize(meshopt_simplifySloppy(
//             lod.data(), unsigned_indices.data(), unsigned_indices.size(),
//             &meshopt_vertices.data()[0].px, meshopt_vertices.size(),
//             sizeof(Vertex), target_index_count));
//       }
//       size_t total_vertices = meshopt_vertices.size();
//       size_t total_indices = lod.size();
//       meshopt_optimizeVertexCache(lod.data(), lod.data(), total_indices,
//                                   total_vertices);
//       meshopt_optimizeOverdraw(lod.data(), lod.data(), total_indices,
//                                &meshopt_vertices.data()[0].px, total_vertices,
//                                sizeof(Vertex), 1.0f);
//       Array blend_shape_array =
//           VisualServer::get_singleton()->mesh_surface_get_blend_shape_arrays(
//               mesh->get_rid(), j);
//       {
//         for (int32_t blend_i = 0; blend_i < blend_shape_array.size();
//              blend_i++) {
//           Array morph = blend_shape_array[blend_i];
//           // Doesn't do anything
//           morph[ArrayMesh::ARRAY_INDEX] = Variant();
//           blend_shape_array[blend_i] = morph;
//         }
//       }
//
//       // TODO
//       // concatenate all LODs into one IB
//       // note: the order of concatenation is important - since we optimize the
//       // entire IB for vertex fetch, putting coarse LODs first makes sure that
//       // the vertex range referenced by them is as small as possible some GPUs
//       // process the entire range referenced by the index buffer region so
//       // doing this optimizes the vertex transform cost for coarse LODs this
//       // order also produces much better vertex fetch cache coherency for
//       // coarse LODs (since they're essentially optimized first) somewhat
//       // surprisingly, the vertex fetch cache coherency for fine LODs doesn't
//       // seem to suffer that much.
//
//       Array current_mesh = mesh_array;
//       PoolIntArray indexes;
//       indexes.resize(lod.size());
//       PoolIntArray::Write w = indexes.write();
//       for (int32_t i = 0; i < lod.size(); i++) {
//         w[i] = (int32_t)lod[i];
//       }
//
//       current_mesh[Mesh::ARRAY_INDEX] = indexes;
//
//       result_mesh->add_surface_from_arrays(Mesh::PRIMITIVE_TRIANGLES,
//                                            current_mesh, blend_shape_array);
//
//       if (mesh->surface_get_material(j).is_valid()) {
//         result_mesh->surface_set_material(j, mesh->surface_get_material(j));
//       }
//       result_mesh->set_blend_shape_mode(ArrayMesh::BLEND_SHAPE_MODE_NORMALIZED);
//       lods[current_lod] = lod;
//     }
//     return result_mesh;
// }

void MeshOptimizer::_find_all_mesh_instances(Array r_items, Node *p_current_node,
                                            const Node *p_owner) {
  MeshInstance *mi = Object::cast_to<MeshInstance>(p_current_node);
  if (mi != NULL && mi->get_mesh().is_valid()) {
    r_items.push_back(mi);
  }
  for (int32_t i = 0; i < p_current_node->get_child_count(); i++) {
    _find_all_mesh_instances(r_items, p_current_node->get_child(i), p_owner);
  }
}
