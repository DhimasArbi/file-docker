docker container run --rm -v hdfs_master_data_swarm:/usr/local/hadoop/data/nameNode dhimasarbi/bdcluster:latest /usr/local/hadoop/bin/hdfs namenode -format

docker service create \
  --name hadoop-namenode \
  --hostname namenode \
  --publish published=8088,target=8088,protocol=tcp,mode=host \
  --publish published=9870,target=9870,protocol=tcp,mode=host \
  --network cluster_net_swarm \
  --mount type=bind,source=/home/zxc/data,target=/home/hadoop/data \
  --mount type=bind,source=/home/zxc/.elepasetting/hadoop/data,target=/usr/local/hadoop/data \
  --mode global \
  --endpoint-mode dnsrr \
  --constraint 'node.labels.role==namenode'\
  dhimasarbi/hadoop:2.10.2 \
  bash -c 'bdcluster initial namenode'

docker service create \
  --name hadoop-datanode1 \
  --hostname datanode1 \
  --mount type=bind,source=/home/zxc/.elepasetting/hadoop/data,target=/usr/local/hadoop/data/dataNode \
  --mount type=volume,source=hdfs_master_checkpoint_data_swarm,target=/usr/local/hadoop/data/namesecondary \
  --network cluster_net_swarm \
  --constraint 'node.labels.role==datanode1' \
  dhimasarbi/hadoop:2.10.2 \
  bash -c 'bdcluster initial'

  mapred

  
  <property>
    <name>mapreduce.application.classpath</name>
    <value>$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*:$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value>
  </property>

docker service create \
  --name hadoop-datanode2 \
  --hostname datanode2 \
  --mount type=bind,source=/home/zxc/.elepasetting/hadoop/data,target=/usr/local/hadoop/data/dataNode \
  --network cluster_net_swarm \
  --constraint 'node.labels.role==datanode2' \
  dhimasarbi/hadoop:2.10.2 \
  bash -c 'bdcluster initial'

docker service create \
  --name datanode3 \
  --hostname datanode3 \
  --mount type=volume,source=hdfs_worker_data_swarm,target=/usr/local/hadoop/data/dataNode \
  --network cluster_net_swarm \
  --constraint 'node.labels.role==worker' \
  dhimasarbi/bdcluster:latest \
  bash -c "/etc/run.sh start"


docker exec -it $(docker container ls --format "{{.Names}}") bash

docker exec -it hadoop-namenode.$(docker service ps hadoop-namenode --no-trunc | grep Running | awk '{split($2,a,"."); print a[2] "." $1}') bash