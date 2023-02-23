# Use the Ubuntu base image
FROM ubuntu:20.04

SHELL ["/bin/bash", "-c"]

# Update the package repository and install Java
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y openjdk-8-jdk nano wget sudo net-tools iputils-ping ssh openssh-server openssh-client &&\
    echo 'ssh:ALL:allow' >> /etc/hosts.allow && \
    echo 'sshd:ALL:allow' >> /etc/hosts.allow && \
    ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    service ssh restart

# Download and extract Hadoop
# RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz && \
COPY hadoop-3.3.4.tar.gz .
RUN tar -xzf hadoop-3.3.4.tar.gz && rm hadoop-3.3.4.tar.gz && \
    mv hadoop-3.3.4 /usr/local/hadoop

# Set the environment variables for Hadoop
ENV HADOOP_HOME "/usr/local/hadoop"
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_YARN_HOME $HADOOP_HOME
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop

# Copy the configuration files
WORKDIR /usr/local/hadoop/etc/hadoop
RUN echo 'export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
COPY ./config/core-site.xml .
COPY ./config/hdfs-site.xml .
COPY ./config/mapred-site.xml .
COPY ./config/yarn-site.xml .



# Adds some needed environment variables
ENV HDFS_NAMENODE_USER "root"
ENV HDFS_DATANODE_USER "root"
ENV HDFS_SECONDARYNAMENODE_USER "root"
ENV YARN_RESOURCEMANAGER_USER "root"
ENV YARN_NODEMANAGER_USER "root"

ENV PATH "$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin"
ENV JAVA_HOME "/usr/lib/jvm/java-8-openjdk-amd64/jre"
ENV PATH $PATH:$JAVA_HOME/bin
ENV PS1='\u@\h:\W $ '

WORKDIR /home/hadoop
COPY ./config/hadoop-cmd.sh .
RUN chmod +x /home/hadoop/hadoop-cmd.sh

WORKDIR /home/user

# Start the Namenode and Datanode
CMD service ssh start && sleep infinity
# CMD ["/home/hadoop/hadoop-cmd.sh", "-Download"]
