#!/bin/bash

set -o nounset \
    -o errexit \
    -o verbose \
    -o xtrace

# Generate CA key
openssl req -new -x509 -keyout sassaman-ca-1.key -out sassaman-ca-1.crt -days 3650 -subj '/CN=ca1.test.confluent.io/OU=TEST/O=CONFLUENT/L=HILVERSUM/S=AMS/C=NL' -passin pass:confluent -passout pass:confluent
# openssl req -new -x509 -keyout sassaman-ca-2.key -out sassaman-ca-2.crt -days 3650 -subj '/CN=ca2.test.confluent.io/OU=TEST/O=CONFLUENT/L=Hilversum/S=AMS/C=NL' -passin pass:confluent -passout pass:confluent

# Kafkacat
openssl genrsa -des3 -passout "pass:confluent" -out kafkacat.client.key 1024
openssl req -passin "pass:confluent" -passout "pass:confluent" -key kafkacat.client.key -new -out kafkacat.client.req -subj '/CN=kafkacat.test.confluent.io/OU=TEST/O=CONFLUENT/L=HILVERSUM/S=AMS/C=NL'
openssl x509 -req -CA sassaman-ca-1.crt -CAkey sassaman-ca-1.key -in kafkacat.client.req -out kafkacat-ca1-signed.pem -days 3650 -CAcreateserial -passin "pass:confluent"



for i in kafka1  producer consumer
do
	echo $i
	# Create keystores
	keytool -genkey -noprompt \
				 -alias $i \
				 -dname "CN=$i.test.confluent.io, OU=TEST, O=CONFLUENT, L=HILVERSUM, S=AMS, C=NL" \
				 -keystore kafka.$i.keystore.jks \
				 -keyalg RSA \
				 -storepass confluent \
				 -keypass confluent

	# Create CSR, sign the key and import back into keystore
	keytool -keystore kafka.$i.keystore.jks -alias $i -certreq -file $i.csr -storepass confluent -keypass confluent

	openssl x509 -req -CA sassaman-ca-1.crt -CAkey sassaman-ca-1.key -in $i.csr -out $i-ca1-signed.crt -days 3650 -CAcreateserial -passin pass:confluent

	keytool -keystore kafka.$i.keystore.jks -alias CARoot -import -file sassaman-ca-1.crt -storepass confluent -keypass confluent

	keytool -keystore kafka.$i.keystore.jks -alias $i -import -file $i-ca1-signed.crt -storepass confluent -keypass confluent

	# Create truststore and import the CA cert.
	keytool -keystore kafka.$i.truststore.jks -alias CARoot -import -file sassaman-ca-1.crt -storepass confluent -keypass confluent

  echo "confluent" > ${i}_sslkey_creds
  echo "confluent" > ${i}_keystore_creds
  echo "confluent" > ${i}_truststore_creds
done