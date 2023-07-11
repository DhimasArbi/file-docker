#!/usr/bin/env bash

is_cid_datanode_same=true
is_cid_name_and_data_same=true
cluster_id_namenode=""
cluster_id_datanode1=""
cluster_id_datanode2=""
cluster_id_datanode3=""
hosts=("datanode1" "datanode2" "datanode3")

start_layanan(){
    if [[ $1 == "all" ]]; then
        echo "Memulai semua layanan HDFS and Yarn"
        /usr/local/hadoop/sbin/start-dfs.sh
        sleep 5
        /usr/local/hadoop/sbin/start-yarn.sh
        sleep 5
    elif [[ $1 == "hdfs" ]]; then
        echo "Memulai layanan HDFS"
        /usr/local/hadoop/sbin/start-dfs.sh
        sleep 5
    elif [[ $1 == "yarn" ]]; then
        echo "Memulai layanan Yarn"
        /usr/local/hadoop/sbin/start-yarn.sh
        sleep 5
    fi
}

start_ssh(){
    echo "Memulai ssh service"
    /usr/sbin/sshd
    sleep 5
}

stop_layanan(){
    if [[ $1 == "all" ]]; then
        echo "Menghentikan semua layanan HDFS and Yarn"
        /usr/local/hadoop/sbin/stop-yarn.sh
        sleep 5
        /usr/local/hadoop/sbin/stop-dfs.sh
        sleep 5
    elif [[ $1 == "hdfs" ]]; then
        echo "Menghentikan layanan HDFS"
        /usr/local/hadoop/sbin/stop-dfs.sh
        sleep 5
    elif [[ $1 == "yarn" ]]; then
        echo "Menghentikan layanan Yarn"
        /usr/local/hadoop/sbin/stop-yarn.sh
        sleep 5
    fi
}

initial(){
    start_ssh
    start_layanan "all"
    if [[ $1 = "namenode" ]]; then
        echo "Disables safe mode to prevent errors in small clusters"
        /usr/local/hadoop/bin/hdfs dfsadmin -safemode leave

        sleep infinity
        exit
    fi
    sleep infinity
    exit
}

format_namenode(){
    if [[ $1 == "clusterid" ]]; then
        /usr/local/hadoop/bin/hdfs namenode -format -clusterId $2 -force
    elif [[ $1 == "normal" ]]; then
        /usr/local/hadoop/bin/hdfs namenode -format
    elif [[ $1 == "force" ]]; then
        /usr/local/hadoop/bin/hdfs namenode -format -force
    fi
}

get_process_name(){
    process_name=$(jps | grep -w "$1" | awk '{print $2}')
    echo "$process_name"
}

get_cid(){
    #Get namenode CID
    if [ -d "/usr/local/hadoop/data/nameNode" ]; then
        cluster_id_namenode=$(cat /usr/local/hadoop/data/nameNode/current/VERSION | awk -F'clusterID=' '{print $2}' | tr -d '[:space:]')
        echo "clusterID namenode: $cluster_id_namenode"
    else
        echo "Namenode belum dimulai!!"
    fi
    for host in "${hosts[@]}"; do
       if ping -c 1 "$host" &> /dev/null; then
            folderExists=$(ssh -o StrictHostKeyChecking=no datanode1 "[ -d '/usr/local/hadoop/data/' ] && \
            echo 'yes'||echo 'no'");
            if [[ $folderExists == "yes" ]]; then
                output=$(ssh -o StrictHostKeyChecking=no $host "cat /usr/local/hadoop/data/dataNode/current/VERSION")
                if [[ $host = "datanode1" ]]; then
                    cluster_id_datanode1=$(echo "$output" | awk -F'clusterID=' '{print $2}' | tr -d '[:space:]')
                    echo "clusterID $host: $cluster_id_datanode1"
                elif [[ $host = "datanode2" ]]; then
                    cluster_id_datanode2=$(echo "$output" | awk -F'clusterID=' '{print $2}' | tr -d '[:space:]')
                    echo "clusterID $host: $cluster_id_datanode2"
                elif [[ $host = "datanode3" ]]; then
                    cluster_id_datanode3=$(echo "$output" | awk -F'clusterID=' '{print $2}' | tr -d '[:space:]')
                    echo "clusterID $host: $cluster_id_datanode3"
                fi
            else
                echo "folder data $host tidak ada, mulai ulang namenode"
            fi
        else
            echo "$host belum dimulai atau host tidak ada!!"
        fi
    done
}

is_cid_same(){
    get_cid
    sleep 3
    if [[ $cluster_id_datanode1 == $cluster_id_datanode2 && $cluster_id_datanode2 == $cluster_id_datanode3 ]]; then
        echo "clusterID dari datanode sama. clusterID: $cluster_id_datanode1"
        is_cid_datanode_same=true
    else
        echo "clusterID dari datanode tidak sama"
        is_cid_datanode_same=false
    fi

    if [[ $is_cid_datanode_same == true && $cluster_id_namenode == $cluster_id_datanode1 ]]; then
        is_cid_name_and_data_same=true
    elif [[ $is_cid_datanode_same == true && $cluster_id_namenode != $cluster_id_datanode1 ]]; then
        is_cid_name_and_data_same=false
    fi
}

rm_folder_data(){
    is_pid_file_exists=$(for i in /tmp/hadoop*; do test -f "$i" && echo "true" && break; done)
    if [[ -d "/usr/local/hadoop/data/nameNode" ]]; then
        echo "Menghapus folder data nameNode"
        rm -rf /usr/local/hadoop/data/nameNode
        if [[ $is_pid_file_exists == "true" ]]; then
            rm -rf /tmp/hadoop*
        fi
        sleep 3
    fi
    for host in "${hosts[@]}"; do
        if ping -c 1 "$host" &> /dev/null; then
            folderExists=$(ssh -o StrictHostKeyChecking=no $host "[ -d '/usr/local/hadoop/data/' ] && \
            echo 'yes'||echo 'no'")
            if [[ $folderExists == 'yes' ]]; then
                echo "Menghapus folder data dataNode pada $host"
                ssh -o StrictHostKeyChecking=no $host "rm -rf /usr/local/hadoop/data/dataNode && rm -rf /tmp/hadoop* && exit"
                sleep 1
            else
                echo "Folder tidak ada!!"
            fi
        else
            echo "$host belum dimulai atau host tidak ada!!"
        fi
    done
}

fix_datanode_na(){
    hdfs_status=$(get_process_name "NameNode")
    yarn_status=$(get_process_name "ResourceManager")
    echo "Memastikan layanan berhenti.."
    sleep 2
    if [[ $hdfs_status != "" && $yarn_status != "" ]]; then
        echo "Layanan $hdfs_status dan $yarn_status masih berjalan. Menghentikan layanan"
        stop_layanan "all"
    elif [[ $hdfs_status == "NameNode" && $yarn_status == "" ]]; then
        echo "Layanan $hdfs_status masih berjalan. Menghentikan layanan"
        stop_layanan "hdfs"
    elif [[ $hdfs_status == "" && $yarn_status == "ResourceManager" ]]; then
        echo "Layanan $yarn_status masih berjalan. Menghentikan layanan"
        stop_layanan "yarn"
    else
        echo -e "Semua layanan telah berhenti.\n"
    fi
    echo -e "Melakukan cek clusterID pada namenode dan datanode...\n"
    is_cid_same
    sleep 2
    if [[ $is_cid_datanode_same == true && $is_cid_name_and_data_same == false ]]; then
        echo -e "clusterID pada namenode tidak sama dengan datanode.\n
                Memformat namenode dengan clusterID: $cluster_id_datanode1"
        format_namenode "clusterid" $cluster_id_datanode1
    elif [[ $is_cid_name_and_data_same == true ]]; then
        rm_folder_data
        format_namenode "force"
    fi
    sleep 5
    echo "Memulai kembali layanan"
    start_layanan "all"
}

if [[ $1 == "initial" ]]; then
    initial $2
elif [[ $1 == "fix" ]]; then
    fix_datanode_na
elif [[ $1 == "format" ]]; then
    format_namenode $2 $3
elif [[ $1 == "stop" ]]; then
    stop_layanan $2
elif [[ $1 == "start" ]]; then
    start_layanan $2
elif [[ $1 == "getcid" ]]; then
    get_cid
fi