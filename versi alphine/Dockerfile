# Gunakan base image Alpine Linux
FROM alpine:latest

USER root
ENV HADOOP_HOME "/usr/local/hadoop"

# Update the package repository dan install Java
RUN apk update && \
    apk add openjdk8 nano wget sudo net-tools iputils openssh

# configure passwordless SSH
RUN apk update && \
    apk add openjdk8-jre nano wget sudo net-tools iputils openssh-server openssh-client && \
    echo 'sshd: ALL' >> /etc/hosts.allow && \
    ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    /etc/init.d/sshd restart


# Tambahkan user dan group hadoop
RUN addgroup -S hadoop && \
    adduser -S -G hadoop hadoop && \
    mkdir -p /home/hadoop && \
    chown -R hadoop:hadoop /home/hadoop

USER hadoop
WORKDIR /home/hadoop

# Download dan extract Hadoop
RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5.tar.gz && \
    tar -xzf hadoop-3.3.5.tar.gz && \
    mv hadoop-3.3.5 $HADOOP_HOME && \
    rm hadoop-3.3.5.tar.gz

# Set environment variables for Hadoop
ENV PATH "$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin"
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_YARN_HOME $HADOOP_HOME
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop

# Copy the configuration files
COPY ./config/core-site.xml $HADOOP_CONF_DIR/core-site.xml
COPY ./config/hdfs-site.xml $HADOOP_CONF_DIR/hdfs-site.xml
COPY ./config/mapred-site.xml $HADOOP_CONF_DIR/mapred-site.xml
COPY ./config/yarn-site.xml $HADOOP_CONF_DIR/yarn-site.xml

# Start the Namenode and Datanode
CMD /usr/sbin/sshd && \
    $HADOOP_HOME/sbin/start-dfs.sh && \
    sleep infinity
