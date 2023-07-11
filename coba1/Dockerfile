FROM eclipse-temurin:8-jdk-alpine as final
FROM alpine:latest as initial

ARG TARGETPLATFORM
ENV HDV=2.10.2
RUN apk update && apk add --no-cache curl

# Download and extract Hadoop
WORKDIR /app
RUN if [[ "$TARGETPLATFORM" == "linux/amd64" ]]; then \
        curl https://dlcdn.apache.org/hadoop/common/stable2/hadoop-$HDV.tar.gz | tar -xz ; \
    fi
        
RUN if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then \
        curl https://dlcdn.apache.org/hadoop/common/stable2/hadoop-$HDV-aarch64.tar.gz | tar -xz ; \
    fi
RUN mv hadoop-$HDV hadoop \
    && echo 'export JAVA_HOME=/opt/java/openjdk' >> /app/hadoop/etc/hadoop/hadoop-env.sh

COPY ./config/run.sh .

# Copy the configuration files
WORKDIR /app/hadoop/etc/hadoop
COPY ./config/core-site.xml \
    ./config/hdfs-site.xml \
    ./config/mapred-site.xml \
    ./config/yarn-site.xml \
    ./config/slaves ./


FROM final

COPY --from=initial  /app/hadoop /usr/local/hadoop
COPY --from=initial  /app/run.sh /etc

RUN apk update && apk add --no-cache openssh bash nano

SHELL ["/bin/bash", "-c"]

# ENV PS1='\u@\h:\w\a\$ '

ENV HADOOP_HOME "/usr/local/hadoop"
ENV PATH $PATH:$JAVA_HOME/bin

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

ENV SSH_OPTIONS="StrictHostKeyChecking=no"

RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

RUN echo 'export PATH=$PATH:$HADOOP_HOME/bin' >> ~/.bashrc \
    && echo 'export PATH=$PATH:$HADOOP_HOME/sbin' >> ~/.bashrc \
    && chmod +x /etc/run.sh

WORKDIR /home/hadoop
RUN mkdir data

CMD /usr/sbin/sshd && sleep infinity