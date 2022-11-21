# Purpose
Demonstrate the use of Confluent Splunk S2S Source Connector and Splunk Connect for Kafka Sink Connector
to collect Splunk Forwarder events in Splunk Enterprise via Kafka.

![overview](./img/AKV%20Kafka%20Splunk.png)

The Splunk Universal Forwarder monitors its own container logs, and forwards them
to the Confluent Splunk S2S Source Connector, which stores them in a predefined Kafka topic.

The Splunk Connect for Kafka Sink Connector consumes records from this Kafka topic,
and sends them to the Splunk Indexer via HEC.

### Resources
The following docker images are used:
* [Confluent Docker Image for Zookeeper](https://hub.docker.com/r/confluentinc/cp-zookeeper) - Tag: 7.3.0
* [Confluent Community Docker Image for Apache Kafka](https://hub.docker.com/r/confluentinc/cp-kafka) - Tag: 7.3.0
* [Confluent Docker Image for Kafka Connect](https://hub.docker.com/r/confluentinc/cp-kafka-connect) - Tag: 7.3.0
* [Splunk Docker Image for Splunk Enterprise (Docker-Splunk)](https://hub.docker.com/r/splunk/splunk) - Tag: 9.0.2
* [Splunk Docker Image for Splunk Universal Forwarder](https://hub.docker.com/r/splunk/universalforwarder) - Tag: 9.0.2

The following Connectors are used:
* [Confluent Splunk S2S Source Connector](https://www.confluent.io/hub/confluentinc/kafka-connect-splunk-s2s) - Version 1.3.1
* [Splunk Connect for Kafka (Splunk Sink Connector)](https://github.com/splunk/kafka-connect-splunk/releases) - Version 2.0.9

### Issues
The [released splunk-kafka-connect-v2.0.9.jar](https://github.com/splunk/kafka-connect-splunk/releases) could not be loaded by Kafka Connect. I resolved the issue by cloning the [repository](https://github.com/splunk/kafka-connect-splunk.git) and building `splunk-kafka-connect-v2.0.9.jar` locally; this might have to do with java version incompatibility.

### Assumptions
Some commands in this README assume that you have `jq` installed. `jq` is used in some commands to format the json output of some `curl` commands.

You can either [download jq](https://stedolan.github.io/jq/) or modify the `curl` commands by removing the trailing ` | jq .` part.

# Quick Start
Do the following to run this demo.
## Clone locally
Clone this repository locally:
```
git clone https://github.com/aggever/akv-kafka-splunk.git
cd akv-kafka-splunk
```
## Download the Connectors
Download the [Confluent Splunk S2S Source Connector](https://www.confluent.io/hub/confluentinc/kafka-connect-splunk-s2s). Unzip the downloaded file in [./kafka-connect/jars/](./kafka-connect/jars/).

Download the [Splunk Sink Connector](https://github.com/splunk/kafka-connect-splunk/releases) and save it in [./kafka-connect/jars/](./kafka-connect/jars/).
## Build the custom Universal Forwarder image
This demo uses a custom Universal Forwarder image, which is based on the [Splunk Docker Image for Splunk Universal Forwarder](https://hub.docker.com/r/splunk/universalforwarder) official image.
The custom image just sets up the Forwarder output configuration to be the Kafka S2S Connector.
To build the image, do:
```
./docker-build.sh
```
## Run
Execute the run script:
```
./run.sh
```
## Verify container statuses
* Verify that all containers are up:
    ```
    docker ps
    ```
## Verify Connector statuses
It will take some time until all services are initialized and running.

You can use the kafka Connect REST Interface to get the active connectors:
```
curl -sS http://localhost:8083/connectors | jq .
```
When the connectors are up, the output should be as follows:
```json
[
  "SplunkSinkConnector",
  "SplunkS2SSourceConnector"
]
```
Using the Connect REST Inteface, you can also check the configuration of each connector, for example:
```
curl -sS http://localhost:8083/connectors/SplunkSinkConnector | jq .
```
The output should be as follows:
```json
{
  "name": "SplunkSinkConnector",
  "config": {
    "connector.class": "com.splunk.kafka.connect.SplunkSinkConnector",
    "splunk.hec.raw": "false",
    "tasks.max": "1",
    "topics": "splunk_topic",
    "name": "SplunkSinkConnector",
    "splunk.hec.ack.enabled": "false",
    "splunk.indexes": "main",
    "splunk.hec.total.channels": "2",
    "splunk.hec.token": "751ba372-ae65-4722-b2a8-058e149d19ac",
    "splunk.hec.uri": "http://splunk:8088"
  },
  "tasks": [
    {
      "connector": "SplunkSinkConnector",
      "task": 0
    }
  ],
  "type": "sink"
}
```

## Login to Splunk Server
Splunk should be available at http://localhost:8000.
Log in using "admin/ch@ngeM3".

## Verify Splunk HEC Token exists
Verify that that the `splunk_hec_token` exists for the HTTP Event Collector at [Data Inputs » HTTP Event Collector](http://localhost:8000/en-GB/manager/launcher/http-eventcollector#). The token is defined in [./splunk/server/default.yml](./splunk/server/default.yml) and it is automatically created.

You can also manually create a HEC token from the Splunk Web UI, and then modify file [splunk-sink-connector.properties](./kafka-connect/conf/splunk-sink-connector.properties) so that the `splunk.hec.token` property has the new token value.

## Verify that events are arriving in Splunk
The Splunk Sink Connector is adding data to the Splunk `main` index. You can search for events added by the Sink Connector at [Apps » Search & Reporting](http://localhost:8000/en-GB/app/search/search?q=search%20index%3D%22main%22), by entering `index="main"` into the input box.


## Cleanup
To destroy the environment, do:
```
./destroy.sh
```

# Documentation

## Splunk Connect for Kafka
Splunk Connect for Kafka is a Kafka Sink Connector allowing Splunk data ingestion from Kafka topics via [Splunk HTTP Event Collector(HEC)](https://dev.splunk.com/enterprise/docs/devtools/httpeventcollector/).

For more information, refer to:
* [GitHub repository](https://github.com/splunk/kafka-connect-splunk)
* [Splunk documentation](https://docs.splunk.com/Documentation/KafkaConnect/2.0.9/User/About)
* [Splunk Connect for Kafka – Connecting Apache Kafka with Splunk](https://www.splunk.com/en_us/blog/tips-and-tricks/splunk-connect-for-kafka-connecting-apache-kafka-with-splunk.html)

## Confluent Splunk S2S Source Connector
The Splunk S2S Source connector provides a way to integrate Splunk with Apache Kafka®. The connector receives data from Splunk universal forwarder (UF) or Splunk heavy forwarder (HF).

For more information, refer to:
* [Splunk S2S Source Connector for Confluent Platform](https://docs.confluent.io/kafka-connectors/splunk-s2s/current/overview.html#splunk-s2s-source-connector-for-cp)

##  Containerized Splunk Enterprise and Splunk Universal Forwarder deployments
For more information on the Docker images for Splunk Enterprise and the Splunk Universal Forwarder, refer to:
* [Docker-Splunk documentation](https://splunk.github.io/docker-splunk/)