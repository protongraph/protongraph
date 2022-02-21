#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <iostream>
#include <fstream>
#include <algorithm>
#include "./utility.h"
#include <syslog.h>

int log_level = 1;

struct produce_cb_params {
    int msg_count;
    int err_count;
    int offset;
    int partition;
    int errmsg_len;
    char *err_msg;
};

/**
 * @brief Reads a file and returns contents as string.
 * 
 * @param path 
 * @return std::string
 */
std::string readFile4(const std::string& filename)
{
    std::ifstream infile(filename.c_str());

    std::string data;
    data.reserve(infile.tellg());
    infile.seekg(0, std::ios::beg);
    data.append(std::istreambuf_iterator<char>(infile.rdbuf()),
                std::istreambuf_iterator<char>());
    // std::cout << data; // Debugging only
    return data;
}

std::string toLower(std::string& data)
{
    std::for_each(data.begin(), data.end(), [](char & c) {
        c = ::tolower(c);
    });
    return data;
}

/**
 * @brief Message delivery report callback.
 *
 * This callback is called exactly once per message, indicating if
 * the message was succesfully delivered
 * (rkmessage->err == RD_KAFKA_RESP_ERR_NO_ERROR) or permanently
 * failed delivery (rkmessage->err != RD_KAFKA_RESP_ERR_NO_ERROR).
 *
 * The callback is triggered from rd_kafka_poll() and executes on
 * the application's thread.
 */
void dr_msg_cb(rd_kafka_t *rk, const rd_kafka_message_t *rkmessage, void *opaque) {
  if (rkmessage->err)
    fprintf(stderr, "%% Message delivery failed: %s\n",
      rd_kafka_err2str(rkmessage->err));
  else
    fprintf(stderr,
      "%% Message delivered (%zd bytes, "
      "partition %" PRId32 ")\n",
      rkmessage->len, rkmessage->partition);

  /* The rkmessage is destroyed automatically by librdkafka */
}

// https://github.com/dwieland/phpkafka/blob/master/kafka.c
void kafka_produce_cb_simple(rd_kafka_t *rk, void *payload, size_t len, rd_kafka_resp_err_t err_code, void *opaque, produce_cb_params *msg_opaque)
{
    struct produce_cb_params *params = msg_opaque;
    if (params)
    {
        params->msg_count -=1;
    }
    if (log_level)
    {
        if (params)
            params->err_count += 1;
        openlog("protongraph", 0, LOG_USER);
        if (err_code)
            syslog(LOG_ERR, "Failed to deliver message %s: %s", (char *) payload, rd_kafka_err2str(err_code));
        else
            syslog(LOG_DEBUG, "Successfully delivered message (%zd bytes)", len);
    }
}

void kafka_produce_detailed_cb(rd_kafka_t *rk, rd_kafka_message_t const *msg, void *opaque)
{
    std::cout << "Message attempt made for payload: " << msg << std::endl;
    struct produce_cb_params *params = (produce_cb_params *)opaque;
    if (params)
    {
        params->msg_count -= 1;
    }
    if (msg->err)
    {
        int offset = params->errmsg_len,
            err_len = 0;
        const char *errstr = rd_kafka_message_errstr(msg);
        err_len = strlen(errstr);
        if (log_level)
        {
            openlog("protongraph", 0, LOG_USER);
            syslog(LOG_ERR, "Failed to deliver message: %s", errstr);
        }
        if (params)
        {
            params->err_count += 1;
            params->err_msg = (char *)(realloc(
                params->err_msg,
                (offset + err_len + 2) * sizeof params->err_msg
            ));
            if (params->err_msg == NULL)
            {
                params->errmsg_len = 0;
            }
            else
            {
                strcpy(
                    params->err_msg + offset,
                    errstr
                );
                offset += err_len;//get new strlen
                params->err_msg[offset] = '\n';//add new line
                ++offset;
                params->err_msg[offset] = '\0';//ensure zero terminated string
            }
        }
        return;
    }
    if (params)
    {
        params->offset = msg->offset;
        params->partition = msg->partition;
    }
}

/**
 * @returns 1 if all bytes are printable, else 0.
 */
int is_printable(const char *buf, size_t size) {
  size_t i;

  for (i = 0; i < size; i++)
    if (!isprint((int)buf[i]))
      return 0;

  return 1;
}