# Use the Ubuntu base image
FROM ubuntu:20.04

ENV HADOOP_HOME "/usr/local/hadoop"

SHELL ["/bin/bash", "-c"]

# Update the package repository and install Java
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get install -y openjdk-8-jdk nano wget sudo net-tools iputils-ping ssh openssh-server openssh-client &&\
    echo 'ssh:ALL:allow' >> /etc/hosts.allow && \
    echo 'sshd:ALL:allow' >> /etc/hosts.allow && \
    ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    service ssh restart

# Download and extract Hadoop
COPY hadoop-3.3.5.tar.gz .
# RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5.tar.gz && \
RUN tar -xzf hadoop-3.3.5.tar.gz \
    && mv hadoop-3.3.5 /usr/local/hadoop \
    && echo 'export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
    && echo 'export PATH=$PATH:$HADOOP_HOME/bin' >> ~/.bashrc \
    && echo 'export PATH=$PATH:$HADOOP_HOME/sbin' >> ~/.bashrc \
    && rm hadoop-3.3.5.tar.gz

# Set the environment variables for Hadoop
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_YARN_HOME $HADOOP_HOME
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop

# Adds some needed environment variables
ENV HDFS_NAMENODE_USER "root"
ENV HDFS_DATANODE_USER "root"
ENV HDFS_SECONDARYNAMENODE_USER "root"
ENV YARN_RESOURCEMANAGER_USER "root"
ENV YARN_NODEMANAGER_USER "root"

# ENV PS1='\u@\h:\W $ '

# Copy the configuration files
WORKDIR /usr/local/hadoop/etc/hadoop
RUN echo 'export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
COPY ./config/core-site.xml .
COPY ./config/hdfs-site.xml .
COPY ./config/mapred-site.xml .
COPY ./config/yarn-site.xml .

WORKDIR /etc
RUN mkdir bdcluster && cd bdcluster
COPY ./config/hadoop-cmd.sh .
RUN chmod +x /etc/bdcluster/hadoop-cmd.sh

WORKDIR /home/user
RUN mkdir data

# Start the Namenode and Datanode
CMD service ssh start && sleep infinity
