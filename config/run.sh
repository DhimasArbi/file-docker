#!/bin/bash

service ssh start

echo "Memulai layanan HDFS and Yarn"
$HADOOP_HOME/sbin/start-dfs.sh
sleep 5
$HADOOP_HOME/sbin/start-yarn.sh
sleep 5

if [[ $1 = "start" ]]; then
    if [[ $2 = "namenode" ]]; then
        echo "Disables safe mode to prevent errors in small clusters"
        /usr/local/hadoop/bin/hdfs dfsadmin -safemode leave

        sleep infinity
        exit
    fi

    sleep infinity
    exit
fi

if [[ $1 = "stop" ]]; then
    echo "Menghentikan HDFS and Yarn"
    $HADOOP_HOME/sbin/stop-dfs.sh
    sleep 5
    $HADOOP_HOME/sbin/stop-yarn.sh
    sleep 5

    exit
fi