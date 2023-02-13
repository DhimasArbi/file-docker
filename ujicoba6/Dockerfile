# Use the Ubuntu base image
FROM alpine:3.12 as initial

USER root

# Update the package repository and install Java
RUN apk update && apk add --no-cache openjdk8-jdk bash procps

# Download and extract Hadoop
# RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz && \
COPY ../hadoop-3.3.4.tar.gz .
RUN tar -xzf hadoop-3.3.4.tar.gz && rm hadoop-3.3.4.tar.gz && \
    mv hadoop-3.3.4 hadoop

# Copy the configuration files
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh
COPY ../config/core-site.xml /usr/local/hadoop/etc/hadoop/
COPY ../config/hdfs-site.xml /usr/local/hadoop/etc/hadoop/
COPY ../config/mapred-site.xml /usr/local/hadoop/etc/hadoop/
COPY ../config/yarn-site.xml /usr/local/hadoop/etc/hadoop/

FROM alpine:3.12
COPY --from=initial /hadoop /usr/local/hadoop

# Set the environment variables for Hadoop
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH "$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin"
ENV JAVA_HOME "/usr/lib/jvm/java-8-openjdk/jre"
ENV PATH $PATH:$JAVA_HOME/bin

ENV HADOOP_PREFIX $HADOOP_HOME
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_YARN_HOME $HADOOP_HOME
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV PS1='\u@\h:\W $ '

# Start the Namenode and Datanode
CMD ["/bin/bash"]
