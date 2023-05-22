# Use the Ubuntu base image
FROM ubuntu:latest

ARG TARGETPLATFORM

ENV HADOOP_HOME "/usr/local/hadoop"

SHELL ["/bin/bash", "-c"]

# Update the package repository and install Java
ENV DEBIAN_FRONTEND noninteractive
RUN apt update
RUN apt install -y openjdk-8-jdk nano wget sudo iputils-ping ssh openssh-server openssh-client
RUN apt clean
RUN echo 'ssh:ALL:allow' >> /etc/hosts.allow && \
    echo 'sshd:ALL:allow' >> /etc/hosts.allow
RUN ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN service ssh restart

# Download and extract Hadoop
#COPY hadoop-3.3.5.tar.gz .
#RUN wget https://dlcdn.apache.org/hadoop/common/stable/hadoop-3.3.5.tar.gz && tar -xzf hadoop-3.3.5.tar.gz && rm hadoop-3.3.5.tar.gz 
RUN if [[ "$TARGETPLATFORM" = "linux/amd64" ]]; then \
wget https://dlcdn.apache.org/hadoop/common/stable/hadoop-3.3.5.tar.gz && \
tar -xzf hadoop-3.3.5.tar.gz && rm hadoop-3.3.5.tar.gz ; \
elif [[ "$TARGETPLATFORM" = "linux/arm64" ]]; then \
wget https://dlcdn.apache.org/hadoop/common/stable/hadoop-3.3.5-aarch64.tar.gz && \
tar -xzf hadoop-3.3.5-aarch64.tar.gz && rm hadoop-3.3.5-aarch64.tar.gz ; fi

RUN mv hadoop-3.3.5 /usr/local/hadoop \
    && echo 'export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
    && echo 'export PATH=$PATH:$HADOOP_HOME/bin' >> ~/.bashrc \
    && echo 'export PATH=$PATH:$HADOOP_HOME/sbin' >> ~/.bashrc 

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
COPY ./config/workers .

WORKDIR /etc
COPY ./config/run.sh .
RUN chmod +x /etc/run.sh

# Add the alias commands to .bashrc
RUN echo 'alias stop="/etc/run.sh stop"' >> /root/.bashrc && \
    echo 'alias start="/etc/run.sh start"' >> /root/.bashrc && \
    echo 'alias fix="/etc/run.sh -f"' >> /root/.bashrc && \
    echo 'alias format="/etc/run.sh -format"' >> /root/.bashrc && \
    echo 'alias init="/etc/run.sh initial"' >> /root/.bashrc && \
    echo 'alias getcid="/etc/run.sh getcid"' >> /root/.bashrc

WORKDIR /home/hadoop
RUN mkdir data

# Start the Namenode and Datanode
CMD service ssh start && sleep infinity
