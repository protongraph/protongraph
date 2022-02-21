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
#include "../lib/src/rdkafka.h"

namespace godot {

class LibRdKafka : public Reference {
    GODOT_CLASS(LibRdKafka, Reference);

// Private variables for domain, broker, broker_password, and topic.
private:
    std::string pw_domain;
    std::string pw_broker;
    std::string pw_broker_password;
    std::string pw_topic;
    bool pw_config_not_found;
    bool pw_secured;
    std::string pw_ssl_ca_pem;
    std::string pw_ssl_certificate_pem;
    std::string pw_ssl_key_pem;
    rd_kafka_t *pw_producer;

public:
    bool has_config();
    void set_config();
    void set_secrets();
    // void _rd_kafka_abort_transaction();
    void _init(); // Initialize the class; required by GDNative --- because otherwise the program will panic, and panics are bad for the digestion! Or, ah, rather throughout back to Kafka :P
    void _finalize(); // Finalize the class; required by GDNative --- because otherwise memory leaks will occur.
    static void _register_methods();
    int init_producer();
    void produce(String message);
     LibRdKafka();
    ~LibRdKafka();
};

}

#endif