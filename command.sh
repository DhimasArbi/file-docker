docker container run --rm -v hdfs_master_data_swarm:/home/hadoop/data/nameNode dhimasarbi/bdcluster:alpine /usr/local/hadoop/bin/hadoop namenode -format

docker service create \
  --name hadoop-node021 \
  --hostname namenode \
  --publish published=8088,target=8088,protocol=tcp,mode=host \
  --publish published=8080,target=8080,protocol=tcp,mode=host \
  --publish published=9870,target=9870,protocol=tcp,mode=host \
  --publish published=18080,target=18080,protocol=tcp,mode=host \
  --network cluster_net_swarm \
  --mount type=bind,source=/home/hadoop/data,target=/home/big_data/data \
  --mount type=volume,source=hdfs_master_data_swarm,target=/home/hadoop/data/nameNode \
  --mount type=volume,source=hdfs_master_checkpoint_data_swarm,target=/home/hadoop/data/namesecondary \
  --mode global \
  --endpoint-mode dnsrr \
  --constraint 'node.labels.role==master'\
  dhimasarbi/bdcluster:alpine \
  bash -c "/usr/run.sh start namenode"

docker service create \
  --name hadoop-node022 \
  --hostname datanode1 \
  --mount type=volume,source=hdfs_worker_data_swarm,target=/home/hadoop/data/dataNode \
  --network cluster_net_swarm \
  --constraint 'node.labels.role==worker' \
  dhimasarbi/bdcluster:alpine \
  bash -c "/usr/run.sh start"

docker service create \
  --name hadoop-node023 \
  --hostname datanode2 \
  --mount type=volume,source=hdfs_worker_data_swarm,target=/home/hadoop/data/dataNode \
  --network cluster_net_swarm \
  --constraint 'node.labels.role==worker' \
  dhimasarbi/bdcluster:alpine \
  bash -c "/usr/run.sh start"

docker service create \
  --name hadoop-node024 \
  --hostname datanode3 \
  --mount type=volume,source=hdfs_worker_data_swarm,target=/home/hadoop/data/dataNode \
  --network cluster_net_swarm \
  --constraint 'node.labels.role==worker' \
  dhimasarbi/bdcluster:alpine \
  bash -c "/usr/run.sh start"


docker exec -it $(docker container ls --format "{{.Names}}") bash