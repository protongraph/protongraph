#ifndef Utility_H
#define Utility_H

#include <stdio.h>
#include <fstream>
#include "../lib/src/rdkafka.h"

std::string readFile4(const std::string& filename);
std::string toLower(std::string& data);
void dr_msg_cb(rd_kafka_t *rk, const rd_kafka_message_t *rkmessage, void *opaque);
void kafka_produce_cb_simple(rd_kafka_t *rk, void *payload, size_t len, rd_kafka_resp_err_t err_code, void *opaque, void *msg_opaque);
void kafka_produce_detailed_cb(rd_kafka_t *rk, rd_kafka_message_t const *msg, void *opaque);
int is_printable(const char *buf, size_t size);
#endif