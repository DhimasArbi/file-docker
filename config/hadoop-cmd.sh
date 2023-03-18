#!/bin/bash

: ${HADOOP_HOME:=/usr/local/hadoop}
service ssh start

echo "Starting HDFS and Yarn"
$HADOOP_HOME/sbin/start-dfs.sh
sleep 5
$HADOOP_HOME/sbin/start-yarn.sh
sleep 5

if [[ $1 = "start" ]]; then
    if [[ $2 = "namenode" ]]; then
        # Disables safe mode to prevent errors in small clusters
        $HADOOP_HOME/bin/hdfs dfsadmin -safemode leave

        sleep infinity
        exit
    fi
    exit
fi