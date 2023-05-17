# Gunakan base image Alpine Linux
FROM alpine:latest

ARG TARGETPLATFORM

USER root

# set Hadoop enviroments
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Update the package repository dan install Java
RUN apk update
RUN apk add --no-cache openssh nano openssl openjdk8-jre rsync bash procps nss

# set JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:$JAVA_HOME/bin

# configure passwordless SSH
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN /usr/sbin/sshd

# Download dan extract Hadoop
#COPY hadoop-3.3.5.tar.gz .
#RUN wget -O hadoop.tar.gz https://dlcdn.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5.tar.gz && \

RUN if [[ "$TARGETPLATFORM" = "linux/amd64" ]]; then \
wget https://dlcdn.apache.org/hadoop/common/stable/hadoop-3.3.5.tar.gz && \
tar -xzf hadoop-3.3.5.tar.gz && rm hadoop-3.3.5.tar.gz ; \
elif [[ "$TARGETPLATFORM" = "linux/arm64" ]]; then \
wget https://dlcdn.apache.org/hadoop/common/stable/hadoop-3.3.5-aarch64.tar.gz && \
tar -xzf hadoop-3.3.5-aarch64.tar.gz && rm hadoop-3.3.5-aarch64.tar.gz ; fi

# create a soft link to make it transparent when upgrade Hadoop
RUN mv hadoop-3.3.5 /usr/local/hadoop

# Set environment variables for Hadoop
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

# Copy the configuration files
WORKDIR /usr/local/hadoop/etc/hadoop
COPY ./config/core-site.xml .
COPY ./config/hdfs-site.xml .
COPY ./config/mapred-site.xml .
COPY ./config/yarn-site.xml .
COPY ./config/workers .

# update JAVA_HOME and HADOOP_CONF_DIR in hadoop-env.sh
RUN sed -i "/^export JAVA_HOME/ s:.*:export JAVA_HOME=${JAVA_HOME}\nexport HADOOP_HOME=${HADOOP_HOME}\nexport HADOOP_HOME=${HADOOP_HOME}:" ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh
RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/:' $HADOOP_HOME/etc/hadoop/hadoop-env.sh

WORKDIR /etc
COPY ./config/run.sh .
RUN chmod +x /etc/run.sh

WORKDIR /home/user
RUN mkdir data

# Start the Namenode and Datanode
# CMD /bin/bash -c "/usr/sbin/sshd && while true; do sleep 1; done"
CMD ["/etc/run.sh", "-d"]
