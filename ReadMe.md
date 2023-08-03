## Kafka Cluster with SSL

This repo has the infrastructure and code for creating a ssl secured kafka cluster.

#### Generate the required certs for setting up the ssl secured cluster

- Navigate to the secrets directory

- Run the below command

```bash
$ cd secrets/
$ sh create-certs.sh
```

- Run the docker compose for a ssl secured kafka cluster
```bash
$ cd ..
$ docker-compose up
```

#### Produce/Consumer Messages in a SSL Secured Environment
- Produce Messages to the topic.

```bash
$ docker exec -it kafka1 bash
$ kafka-console-producer --bootstrap-server localhost:9092 \
--topic test-topic \
--producer.config /etc/kafka/properties/producer.properties
```

- Consume Messages from the topic.

```bash
$ docker exec -it kafka1 bash
$ kafka-console-consumer --bootstrap-server localhost:9092 \
--topic test-topic \
--from-beginning \
--consumer.config /etc/kafka/properties/consumer.properties
```

```bash
$ docker exec -it kafka1 bash
$ kafka-console-consumer --bootstrap-server localhost:9092 \
--topic library-events \
--from-beginning \
--consumer.config /etc/kafka/properties/consumer.properties
```