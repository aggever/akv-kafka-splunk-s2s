#!/bin/bash

echo -e "Starting services..."
docker compose up -d

# Create the `splunk_topic` topic
echo -e "Creating the 'splunk_topic' kafka topic..."
docker compose \
    exec broker kafka-topics \
    --create \
    --topic splunk_topic \
    --bootstrap-server localhost:9092 \
    --replication-factor 1 \
    --partitions 1 \
    --if-not-exists

echo -e "Finished. The Universal Forwarder will start sending events to the Kafka S2S Connector."
echo -e "You can search Splunk for events at http://localhost:8000/en-GB/app/search/search?q=search%20index%3D%22main%22"

echo -e "Exiting"

exit 0
