FROM alpine:latest

ARG TARGETPLATFORM

RUN apk update && apk add --no-cache openssh openssl bash nano procps openjdk8-jre curl

SHELL ["/bin/bash", "-c"]

ENV PS1='\u@\h:\w\a\$ '

ENV HADOOP_HOME "/usr/local/hadoop"
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:$JAVA_HOME/bin

RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

RUN if [[ "$TARGETPLATFORM" = "linux/amd64" ]]; then \
curl -LO https://dlcdn.apache.org/hadoop/common/stable/hadoop-3.3.5.tar.gz && \
tar -xzf hadoop-3.3.5.tar.gz && rm hadoop-3.3.5.tar.gz ; \
elif [[ "$TARGETPLATFORM" = "linux/arm64" ]]; then \
curl -LO https://dlcdn.apache.org/hadoop/common/stable/hadoop-3.3.5-aarch64.tar.gz && \
tar -xzf hadoop-3.3.5-aarch64.tar.gz && rm hadoop-3.3.5-aarch64.tar.gz ; fi

# RUN curl -LO -O hadoop.tar.gz https://dlcdn.apache.org/hadoop/common/stable/hadoop-3.3.5-aarch64.tar.gz
# RUN tar -xzf hadoop.tar.gz && rm hadoop.tar.gz

RUN mv hadoop-3.3.5 /usr/local/hadoop
RUN echo 'export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
    && echo 'export PATH=$PATH:$HADOOP_HOME/bin' >> ~/.bashrc \
    && echo 'export PATH=$PATH:$HADOOP_HOME/sbin' >> ~/.bashrc 

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

# RUN sed -i "/^export JAVA_HOME/ s:.*:export JAVA_HOME=${JAVA_HOME}\nexport HADOOP_HOME=${HADOOP_HOME}\nexport HADOOP_HOME=${HADOOP_HOME}:" ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh
# RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/:' $HADOOP_HOME/etc/hadoop/hadoop-env.sh

WORKDIR /etc
COPY ./config/run.sh .
RUN chmod +x /etc/run.sh

WORKDIR /home/hadoop
RUN mkdir data

CMD /usr/sbin/sshd && sleep infinity