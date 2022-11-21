FROM splunk/universalforwarder:8.1.12
USER splunk
#COPY splunk/forwarder/conf/inputs.conf /opt/splunkforwarder/etc/system/local/inputs.conf
COPY splunk/forwarder/conf/outputs.conf /opt/splunkforwarder/etc/system/local/outputs.conf
USER ansible