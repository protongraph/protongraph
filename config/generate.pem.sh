#!/bin/bash

##################################
### localhost ####################
##################################

rm -r secrets
mkdir secrets

## 1. Create certificate authority (CA)
openssl req -new -sha256 -x509 -keyout secrets/ca-key-localhost -out secrets/ca-cert-localhost -days 365 -passin pass:$2 -passout pass:$2 -subj "/CN=localhost/OU=ww/O=ee/L=rr/ST=tt/C=yy"

### CLIENT

## 2. Create client keystore
keytool -keystore secrets/kafka.client.keystore.jks -alias localhost -validity 3650 -genkey -keyalg RSA -ext SAN=DNS:localhost -keypass $2 -storepass $2 -dname CN=localhost,OU=ww,O=ee,L=rr,ST=tt,C=yy
## 3. Sign client certificate
keytool -keystore secrets/kafka.client.keystore.jks -alias localhost -certreq -file secrets/client-cert-file-localhost -storepass $2
openssl x509 -req -CA secrets/ca-cert-localhost -CAkey secrets/ca-key-localhost -in secrets/client-cert-file-localhost -out secrets/client-cert-signed-localhost -days 3650 -CAcreateserial -passin pass:$2 -sha256
## 4. Import CA and signed client certificate into client keystore
keytool -keystore secrets/kafka.client.keystore.jks -alias CARoot-localhost -importcert -file secrets/ca-cert-localhost -storepass $2 -noprompt
keytool -keystore secrets/kafka.client.keystore.jks -alias localhost -importcert -file secrets/client-cert-signed-localhost -storepass $2 -noprompt
## 5. Import CA into client truststore (only for debugging with Java consumer)
keytool -noprompt -keystore secrets/kafka.client.truststore.jks -alias CARoot-localhost -import -file secrets/ca-cert-localhost -storepass $2
## 6. Import CA into server truststore
keytool -noprompt -keystore secrets/kafka.server.truststore.jks -alias CARoot-localhost -import -file secrets/ca-cert-localhost -storepass $2

### SERVER

# nb The JKS keystore uses a proprietary format. It is recommended to migrate to PKCS12 which is an industry standard format using "keytool -importkeystore -srckeystore secrets/kafka.server.keystore.jks -destkeystore secrets/kafka.server.keystore.jks -deststoretype pkcs12"

## 2. Create server keystore
keytool -keystore secrets/kafka.server.keystore.jks -alias localhost -validity 3650 -genkey -keyalg RSA -ext SAN=DNS:localhost -keypass $2 -storepass $2 -dname CN=localhost,OU=ww,O=ee,L=rr,ST=tt,C=yy
## 3. Sign server certificate
keytool -keystore secrets/kafka.server.keystore.jks -alias localhost -certreq -file secrets/server-cert-file-localhost -storepass $2
openssl x509 -req -CA secrets/ca-cert-localhost -CAkey secrets/ca-key-localhost -in secrets/server-cert-file-localhost -out secrets/server-cert-signed-localhost -days 3650 -CAcreateserial -passin pass:$2 -sha256
## 4. Import CA and signed server certificate into server keystore
keytool -keystore secrets/kafka.server.keystore.jks -alias CARoot-localhost -importcert -file secrets/ca-cert-localhost -storepass $2 -noprompt
keytool -keystore secrets/kafka.server.keystore.jks -alias localhost -importcert -file secrets/server-cert-signed-localhost -storepass $2 -noprompt

##################################
### Kafka VM: subdomain.domain eg kafka.yourfavoureddomain.com ##############
##################################

## 1. Create certificate authority (CA)
echo "Creating certificate authority (CA)..."
echo "-subj params CN=$1,OU=ww,O=ee,L=rr,ST=tt,C=yy"
openssl req -new -sha256 -x509 -keyout secrets/ca-key-$1 -out secrets/ca-cert-$1 -days 365 -passin pass:$2 -passout pass:$2 -subj "/CN=$1/OU=ww/O=ee/L=rr/ST=tt/C=yy"

### CLIENT

## nb The JKS keystore uses a proprietary format. It is recommended to migrate to PKCS12 which is an industry standard format using "keytool -importkeystore -srckeystore secrets/kafka.client.keystore.jks -destkeystore secrets/kafka.client.keystore.jks -deststoretype pkcs12".

## 2. Create client keystore
keytool -keystore secrets/kafka.client.keystore.jks -alias $1 -validity 3650 -genkey -keyalg RSA -ext SAN=DNS:$1 -keypass $2 -storepass $2 -dname CN=$1,OU=ww,O=ee,L=rr,ST=tt,C=yy
## 3. Sign client certificate
keytool -keystore secrets/kafka.client.keystore.jks -alias $1 -certreq -file secrets/client-cert-file-$1 -storepass $2
openssl x509 -req -CA secrets/ca-cert-$1 -CAkey secrets/ca-key-$1 -in secrets/client-cert-file-$1 -out secrets/client-cert-signed-$1 -days 3650 -CAcreateserial -passin pass:$2 -sha256
## 4. Import CA and signed client certificate into client keystore
keytool -keystore secrets/kafka.client.keystore.jks -alias CARoot-$1 -importcert -file secrets/ca-cert-$1 -storepass $2 -noprompt
keytool -keystore secrets/kafka.client.keystore.jks -alias $1 -importcert -file secrets/client-cert-signed-$1 -storepass $2 -noprompt
## 5. Import CA into client truststore (only for debugging with Java consumer)
keytool -noprompt -keystore secrets/kafka.client.truststore.jks -alias CARoot-$1 -import -file secrets/ca-cert-$1 -storepass $2
## 6. Import CA into server truststore
keytool -noprompt -keystore secrets/kafka.server.truststore.jks -alias CARoot-$1 -import -file secrets/ca-cert-$1 -storepass $2

### SERVER

## 2. Create server keystore
echo "Creating server keystore..."
echo "-dname params CN=$1,OU=ww,O=ee,L=rr,ST=tt,C=yy"
keytool -keystore secrets/kafka.server.keystore.jks -alias $1 -validity 3650 -genkey -keyalg RSA -ext SAN=DNS:$1 -keypass $2 -storepass $2 -dname CN=$1,OU=ww,O=ee,L=rr,ST=tt,C=yy
## 3. Sign server certificate
keytool -keystore secrets/kafka.server.keystore.jks -alias $1 -certreq -file secrets/server-cert-file-$1 -storepass $2
openssl x509 -req -CA secrets/ca-cert-$1 -CAkey secrets/ca-key-$1 -in secrets/server-cert-file-$1 -out secrets/server-cert-signed-$1 -days 3650 -CAcreateserial -passin pass:$2 -sha256
## 4. Import CA and signed server certificate into server keystore
keytool -keystore secrets/kafka.server.keystore.jks -alias CARoot-$1 -importcert -file secrets/ca-cert-$1 -storepass $2 -noprompt
keytool -keystore secrets/kafka.server.keystore.jks -alias $1 -importcert -file secrets/server-cert-signed-$1 -storepass $2 -noprompt

### LOCALMACHINE FOR RUBY-KAFKA

## 7. Create PEM files for Ruby client rel Kafka VM: subdomain.domain eg kafka.yourfavoureddomain.com cert
### 7.1 Extract signed client certificate
keytool -noprompt -keystore secrets/kafka.client.keystore.jks -exportcert -alias $1 -rfc -storepass $2 -file secrets/client_cert-$1.pem
### 7.2 Extract client key
keytool -noprompt -srckeystore secrets/kafka.client.keystore.jks -importkeystore -srcalias $1 -destkeystore secrets/cert_and_key-$1.p12 -deststoretype PKCS12 -srcstorepass $2 -storepass $2
openssl pkcs12 -in secrets/cert_and_key-$1.p12 -nocerts -nodes -passin pass:$2 -out secrets/client_cert_key-$1.pem
### 7.3 Extract CA certificate
keytool -noprompt -keystore secrets/kafka.client.keystore.jks -exportcert -alias CARoot-$1 -rfc -file secrets/ca_cert-$1.pem -storepass $2

## 7. Create PEM files for Ruby client rel localhost cert
### 7.1 Extract signed client certificate
keytool -noprompt -keystore secrets/kafka.client.keystore.jks -exportcert -alias localhost -rfc -storepass $2 -file secrets/client_cert-localhost.pem
### 7.2 Extract client key
keytool -noprompt -srckeystore secrets/kafka.client.keystore.jks -importkeystore -srcalias localhost -destkeystore secrets/cert_and_key-localhost.p12 -deststoretype PKCS12 -srcstorepass $2 -storepass $2
openssl pkcs12 -in secrets/cert_and_key-localhost.p12 -nocerts -nodes -passin pass:$2 -out secrets/client_cert_key-localhost.pem
### 7.3 Extract CA certificate
keytool -noprompt -keystore secrets/kafka.client.keystore.jks -exportcert -alias CARoot-localhost -rfc -file secrets/ca_cert-localhost.pem -storepass $2