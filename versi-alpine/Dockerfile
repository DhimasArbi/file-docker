# Gunakan base image Alpine Linux
FROM alpine:latest

USER root

# set Hadoop enviroments
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Update the package repository dan install Java
RUN apk update && apk add --no-cache openssh openssl openjdk8-jre rsync bash procps nss

# set JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:$JAVA_HOME/bin

# configure passwordless SSH
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN /usr/sbin/sshd

# Download dan extract Hadoop
COPY hadoop-3.3.5.tar.gz .
#RUN wget -O hadoop.tar.gz https://dlcdn.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5.tar.gz && \
RUN tar -xzf hadoop-3.3.5.tar.gz -C /usr/local && rm hadoop-3.3.5.tar.gz

# create a soft link to make it transparent when upgrade Hadoop
RUN ln -s /usr/local/hadoop-3.3.5 /usr/local/hadoop

# Set environment variables for Hadoop
ENV HADOOP_PREFIX $HADOOP_HOME
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
COPY ./config/workers $HADOOP_CONF_DIR/workers

# update JAVA_HOME and HADOOP_CONF_DIR in hadoop-env.sh
RUN sed -i "/^export JAVA_HOME/ s:.*:export JAVA_HOME=${JAVA_HOME}\nexport HADOOP_HOME=${HADOOP_HOME}\nexport HADOOP_PREFIX=${HADOOP_PREFIX}:" ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh
RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

WORKDIR /etc
COPY ./config/run.sh .
RUN chmod +x /etc/run.sh

WORKDIR /home/user
RUN mkdir data

# Start the Namenode and Datanode
# CMD /bin/bash -c "/usr/sbin/sshd && while true; do sleep 1; done"
CMD ["/etc/run.sh", "-d"]
