docker container run --rm -v hdfs_master_data_swarm:/usr/local/hadoop/data/nameNode dhimasarbi/bdcluster:latest /usr/local/hadoop/bin/hdfs namenode -format

docker service create \
  --name namenode \
  --hostname namenode \
  --publish published=8088,target=8088,protocol=tcp,mode=host \
  --publish published=9870,target=9870,protocol=tcp,mode=host \
  --network cluster_net_swarm \
  --mount type=bind,source=/home/hadoop/data,target=/home/user/data \
  --mount type=volume,source=hdfs_master_data_swarm,target=/usr/local/hadoop/data/nameNode \
  --mount type=volume,source=hdfs_master_checkpoint_data_swarm,target=/usr/local/hadoop/data/namesecondary \
  --mode global \
  --endpoint-mode dnsrr \
  --constraint 'node.labels.role==manager'\
  dhimasarbi/bdcluster:latest \
  bash -c "/etc/run.sh start namenode"

docker service create \
  --name datanode1 \
  --hostname datanode1 \
  --mount type=volume,source=hdfs_worker_data_swarm,target=/usr/local/hadoop/data/dataNode \
  --network cluster_net_swarm \
  --constraint 'node.labels.role==worker' \
  dhimasarbi/bdcluster:latest \
  bash -c "/etc/run.sh start"

docker service create \
  --name datanode2 \
  --hostname datanode2 \
  --mount type=volume,source=hdfs_worker_data_swarm,target=/usr/local/hadoop/data/dataNode \
  --network cluster_net_swarm \
  --constraint 'node.labels.role==worker' \
  dhimasarbi/bdcluster:latest \
  bash -c "/etc/run.sh start"

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