#include "librdkafka.h"
#include "../lib/src/rdkafka.h"
#include "../lib/src-cpp/rdkafkacpp.h"
#include <string>
#include <vector>
#include <iostream>
#include <fstream>
#include <sstream>
#include "./utility.h"

using namespace godot;

static volatile sig_atomic_t run = 1;

void sigterm(int sig) {
  run = 0;
}

class ExampleDeliveryReportCb : public RdKafka::DeliveryReportCb {
 public:
  void dr_cb(RdKafka::Message &message) {
    /* If message.err() is non-zero the message delivery failed permanently
     * for the message. */
    if (message.err())
      std::cerr << "% Message delivery failed: " << message.errstr()
                << std::endl;
    else
      std::cerr << "% Message delivered to topic " << message.topic_name()
                << " [" << message.partition() << "] at offset "
                << message.offset() << std::endl;
  }
};

void LibRdKafka::_register_methods() {
  // register_method("_rd_kafka_abort_transaction", &LibRdKafka::_rd_kafka_abort_transaction);
  register_method("has_config", &LibRdKafka::has_config);
  register_method("produce", &LibRdKafka::produce);
}

bool LibRdKafka::has_config() {
  return !pw_config_not_found;
}

// This method is required by GDNative when an object is instantiated.
void LibRdKafka::_init() {}

// This method is required by GDNative when an object is destroyed.
void LibRdKafka::_finalize() {
  LibRdKafka::~LibRdKafka();
}

// Writes a message to the Kafka topic using rd_kafka_producev (the new version of rd_kafka_produce, see https://github.com/edenhill/librdkafka/issues/2732#issuecomment-591312809).
void LibRdKafka::produce(String gd_message) {
  char *message = (char *)gd_message.alloc_c_string();

  std::cout << "Producing to Kafka ..." << std::endl;
  std::cout << "Message from front-end: " << message << std::endl;

  size_t len = strlen(message);
  rd_kafka_resp_err_t err;

  if (message[len - 1] == '\n') /* Remove newline */
    message[--len] = '\0';

  std::cout << "Length of message: " << len << std::endl;

  if (len == 0) {
    /* Empty line: only serve delivery reports */
    rd_kafka_poll(pw_producer, 0 /*non-blocking */);
  }

  /*
    * Send/Produce message.
    * This is an asynchronous call, on success it will only
    * enqueue the message on the internal producer queue.
    * The actual delivery attempts to the broker are handled
    * by background threads.
    * The previously registered delivery report callback
    * (dr_msg_cb) is used to signal back to the application
    * when the message has been delivered (or failed).
    */
retry:
  err = rd_kafka_producev(
    /* Producer handle */
    pw_producer,
    /* Topic name */
    RD_KAFKA_V_TOPIC(pw_topic.c_str()),
    /* Make a copy of the payload. */
    RD_KAFKA_V_MSGFLAGS(RD_KAFKA_MSG_F_COPY),
    /* Message value and length */
    RD_KAFKA_V_VALUE(message, len),
    /* Per-Message opaque, provided in
      * delivery report callback as
      * msg_opaque. */
    RD_KAFKA_V_OPAQUE(NULL),
    /* End sentinel */
    RD_KAFKA_V_END);
  if (err) {
    /*
      * Failed to *enqueue* message for producing.
      */
    fprintf(stderr,
      "%% Failed to produce to topic %s: %s\n", pw_topic.c_str(),
      rd_kafka_err2str(err));

    if (err == RD_KAFKA_RESP_ERR__QUEUE_FULL) {
      /* If the internal queue is full, wait for
        * messages to be delivered and then retry.
        * The internal queue represents both
        * messages to be sent and messages that have
        * been sent or failed, awaiting their
        * delivery report callback to be called.
        *
        * The internal queue is limited by the
        * configuration property
        * queue.buffering.max.messages */
      rd_kafka_poll(pw_producer,
        1000 /*block for max 1000ms*/);
      goto retry;
    }
  } else {
    fprintf(stderr,
      "%% Enqueued message (%zd bytes) "
      "for topic %s\n",
      len, pw_topic.c_str());
  }


  /* A producer application should continually serve
    * the delivery report queue by calling rd_kafka_poll()
    * at frequent intervals.
    * Either put the poll call in your main loop, or in a
    * dedicated thread, or call it after every
    * rd_kafka_produce() call.
    * Just make sure that rd_kafka_poll() is still called
    * during periods where you are not producing any messages
    * to make sure previously produced messages have their
    * delivery report callback served (and any other callbacks
    * you register). */
  rd_kafka_poll(pw_producer, 0 /*non-blocking*/);
}

void LibRdKafka::set_config() {
  std::string config_file_name = "config/kafka.config";
  std::ifstream config_file(config_file_name.c_str());
  std::string line;
  if (config_file.is_open()) {
    while (getline(config_file, line)) {
      std::stringstream ss(line);
      std::string key;
      std::string value;
      std::getline(ss, key, '=');
      std::getline(ss, value);
      if (key == "DOMAIN") {
        pw_domain = value;
      } else if (key == "BROKER") {
        pw_broker = value;
      } else if (key == "BROKER_PASSWORD") {
        pw_broker_password = value;
      } else if (key == "TOPICS") {
        pw_topic = value;
      } else if (key == "SECURED") {
        if (toLower(value) == "true") {
          pw_secured = true;
        } else {
          pw_secured = false;
        }
      }
    }
    config_file.close();
    // We should indicate that the configuration file was read in.
    pw_config_not_found = false;
  } else {
    std::cout << "Unable to open file \n";
    // We should indicate that there is no configuration set for Kafka.
    pw_config_not_found = true;
  }
  std::cout << "Broker: " << pw_broker << std::endl;
  std::cout << "Broker Password: " << pw_broker_password << std::endl;
  std::cout << "Topic: " << pw_topic << std::endl;
  std::cout << "Domain: " << pw_domain << std::endl;
}

void LibRdKafka::set_secrets() {
  if (pw_secured) {
    std::cout << "Domain secured, setting secrets.\n";
    std::string ssl_ca_pem_path = "config/secrets/ca_cert-" + std::string(pw_domain) + ".pem";
    std::string ssl_certificate_pem_path = "config/secrets/client_cert-" + std::string(pw_domain) + ".pem";
    std::string ssl_key_pem_path = "config/secrets/client_cert_key-" + std::string(pw_domain) + ".pem";

    pw_ssl_ca_pem = readFile4(ssl_ca_pem_path.c_str());
    pw_ssl_certificate_pem = readFile4(ssl_certificate_pem_path.c_str());
    pw_ssl_key_pem = readFile4(ssl_key_pem_path.c_str());
  } else {
    std::cout << "Domain not secured, not setting secrets.\n";
  }
}

int LibRdKafka::init_producer() {
  rd_kafka_conf_t *conf;   /* Temporary configuration object */
  rd_kafka_resp_err_t err; /* librdkafka API error code */
  char errstr[512];        /* librdkafka API error reporting buffer */
  const char *domain;      /* Argument: domain name */
  const char *brokers;     /* Argument: broker list */
  const char *broker_password; /* Broker password */
  const char *groupid;     /* Argument: Producer group id */
  char **topics;           /* Argument: list of topics to subscribe to */
  int topic_cnt;           /* Number of topics to subscribe to */
  rd_kafka_topic_partition_list_t *subscription; /* Subscribed topics */
  int i;
  char *message;

  brokers = pw_broker.c_str();
  const char * topic   = pw_topic.c_str();

  // TODO: Need to convert gd_message to message, this could be tricky, need to leverage the GDnative api.
  // TODO: Abstract producer initialisation and produce into separate functions, not just one.

  /*
  * Create Kafka client configuration place-holder
  */
  conf = rd_kafka_conf_new();

  // Each config variable can be set using a writer attribute.

  // Only set SSL information if we are using SSL.
  if (pw_secured) {
    std::cout << "Using SSL, now setting SSL secrets.\n";
    /*
    * Set the SSL context
    */
    rd_kafka_conf_set(conf, "ssl.ca.pem", pw_ssl_ca_pem.data(), errstr, sizeof(errstr));
    rd_kafka_conf_set(conf, "ssl.certificate.pem", pw_ssl_certificate_pem.data(), errstr, sizeof(errstr));
    rd_kafka_conf_set(conf, "ssl.key.pem", pw_ssl_key_pem.data(), errstr, sizeof(errstr));
    rd_kafka_conf_set(conf, "ssl.key.password", pw_broker_password.data(), errstr, sizeof(errstr));
    rd_kafka_conf_set(conf, "security.protocol", "ssl", errstr, sizeof(errstr));
    /* The next line is required otherwise the protongraph provider will complain that the certificates are self-signed (which they are).
      * TODO: purchase? a root certificate from a trusted authority and configure things to verify its authenticity, then
      * remove this line.
      */
    rd_kafka_conf_set(conf, "enable.ssl.certificate.verification", "false", errstr, sizeof(errstr)); // Sets OPENSSL_VERIFY_NONE https://github.com/edenhill/librdkafka/blob/2a8bb418e0eb4655dc88ce9aec3eccb107551ff4/src/rdkafka_ssl.c#L1557-L1558 , https://github.com/edenhill/librdkafka/blob/a82595bea95e291da3608131343fa2fac9f92f83/src/rdkafka_conf.c#L824-L825 .  This gets around issues with self-signed certificates.
  } else {
    std::cout << "Not using SSL, not setting SSL secrets.\n";
    rd_kafka_conf_set(conf, "security.protocol", "plaintext", errstr, sizeof(errstr));
  }
  
  /* Set bootstrap broker(s) as a comma-separated list of
    * host or host:port (default port 9092).
    * librdkafka will use the bootstrap brokers to acquire the full
    * set of brokers from the cluster. */
  if (rd_kafka_conf_set(conf, "bootstrap.servers", brokers, errstr, sizeof(errstr)) != RD_KAFKA_CONF_OK) {
    fprintf(stderr, "%s\n", errstr);
    rd_kafka_conf_destroy(conf);
    return 1;
  }

  signal(SIGINT, sigterm);
  signal(SIGTERM, sigterm);

  /* Set the delivery report callback.
   * This callback will be called once per message to inform
   * the application if delivery succeeded or failed.
   * See dr_msg_cb() above.
   * The callback is only triggered from ::poll() and ::flush().
   *
   * IMPORTANT:
   * Make sure the DeliveryReport instance outlives the Producer object,
   * either by putting it on the heap or as in this case as a stack variable
   * that will NOT go out of scope for the duration of the Producer object.
   */
  ExampleDeliveryReportCb ex_dr_cb;

  // rd_kafka_conf_set_dr_cb(conf, kafka_produce_cb_simple);
  rd_kafka_conf_set_dr_msg_cb(conf, kafka_produce_detailed_cb);

  /*
  * Create producer instance.
  *
  * NOTE: rd_kafka_new() takes ownership of the conf object
  *       and the application must not reference it again after
  *       this call.
  */
  pw_producer = rd_kafka_new(RD_KAFKA_PRODUCER, conf, errstr, sizeof(errstr));
  if (!pw_producer) {
    fprintf(stderr, "%% Failed to create producer: %s\n", errstr);
    return 1;
  }

  conf = NULL; /* Configuration object is now owned, and freed,
                * by the rd_kafka_t instance. */
  return 0;
}

/* Constuctor for LibRdKafka which reads in configuration from the file of the form  
DOMAIN=mydomain.com
BROKER=mydomain.com:9093
BROKER_PASSWORD=mybrokerpassword
TOPICS=mybrokertopictoproduceto

and sets the variables in the LibRdKafka class accordingly.
*/
LibRdKafka::LibRdKafka() {
  int err;
  set_config(); // Set basic configuration.
  if (pw_config_not_found) {
    std::cout << "No config file found, check that you have kafka.config present.\n";
  } else {
    set_secrets(); // Set secrets for communication to secured Kafka VM.
    err = init_producer();
    if (err) {
      std::cout << "Failed to initialise producer.\n";
    }
  }
}

LibRdKafka::~LibRdKafka() {
  /* Wait for final messages to be delivered or fail.
  * rd_kafka_flush() is an abstraction over rd_kafka_poll() which
  * waits for all messages to be delivered. */
  fprintf(stderr, "%% Flushing final messages..\n");
  rd_kafka_flush(pw_producer, 10 * 1000 /* wait for max 10 seconds */);

  /* If the output queue is still not empty there is an issue
    * with producing messages to the clusters. */
  if (rd_kafka_outq_len(pw_producer) > 0)
    fprintf(stderr, "%% %d message(s) were not delivered\n",
      rd_kafka_outq_len(pw_producer));

  /* Destroy the producer instance */
  rd_kafka_destroy(pw_producer);
}

