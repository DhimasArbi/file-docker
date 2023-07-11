FROM alpine:latest as initial

ARG TARGETPLATFORM
ENV HDV=3.3.6
RUN apk update && apk add --no-cache curl

# Download and extract Hadoop
WORKDIR /app
RUN if [[ "$TARGETPLATFORM" == "linux/amd64" ]]; then \
        curl https://dlcdn.apache.org/hadoop/common/stable/hadoop-$HDV.tar.gz | tar -xz ; \
    fi
        
RUN if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then \
        curl https://dlcdn.apache.org/hadoop/common/stable/hadoop-$HDV-aarch64.tar.gz | tar -xz ; \
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
    ./config/workers ./

FROM eclipse-temurin:8-jdk-jammy as build

COPY --from=initial  /app/hadoop /usr/local/hadoop
COPY --from=initial  /app/run.sh /etc

SHELL ["/bin/bash", "-c"]

# Set the environment variables for Hadoop
ENV HADOOP_HOME "/usr/local/hadoop"
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

# Update the package repository and install Java
RUN apt update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt install -y --no-install-recommends \
    nano ssh openssh-server openssh-client \
    && rm -rf /var/lib/apt/lists/* && \
    echo 'ssh:ALL:allow' >> /etc/hosts.allow \
    && echo 'sshd:ALL:allow' >> /etc/hosts.allow \
    && ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo '    StrictHostKeyChecking no' >> /etc/ssh/ssh_config \
    && echo '    UserKnownHostsFile=/dev/null' >> /etc/ssh/ssh_config \
    && echo '    LogLevel ERROR' >> /etc/ssh/ssh_config \
    && service ssh restart && \
    echo 'export PATH=$PATH:$HADOOP_HOME/bin' >> ~/.bashrc \
    && echo 'export PATH=$PATH:$HADOOP_HOME/sbin' >> ~/.bashrc \
    && chmod +x /etc/run.sh && ln -s /etc/run.sh /usr/bin/bdcluster \
    && chmod 700 /usr/bin/bdcluster
# RUN mv hadoop-$HDV /usr/local/hadoop \
# RUN echo 'export JAVA_HOME=/opt/java/openjdk' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \

WORKDIR /home/hadoop
RUN mkdir data

# Start the Namenode and Datanode
CMD service ssh start && sleep infinity
