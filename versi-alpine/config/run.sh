#!/bin/bash

: ${HADOOP_HOME:=/usr/local/hadoop}

/usr/sbin/sshd

if [[ $1 == "start" ]]; then
    echo "Memulai layanan HDFS and Yarn"
    $HADOOP_HOME/sbin/start-dfs.sh
    sleep 5
    $HADOOP_HOME/sbin/start-yarn.sh
    sleep 5
    if [[ $2 = "namenode" ]]; then
        echo "Disables safe mode to prevent errors in small clusters"
        /usr/local/hadoop/bin/hdfs dfsadmin -safemode leave

        while true; do read; done
        exit
    fi

    while true; do read; done
    exit
elif [[ $1 == "-d" ]]; then
  while true; do read; done
elif [[ $1 == "-bash" ]]; then
  /bin/bash
fi

if [[ $1 = "stop" ]]; then
    echo "Menghentikan HDFS and Yarn"
    $HADOOP_HOME/sbin/stop-dfs.sh
    sleep 5
    $HADOOP_HOME/sbin/stop-yarn.sh
    sleep 5
fi

