# Use the Ubuntu base image
FROM ubuntu:20.04 as initial

# Download and extract Hadoop
# RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz && \
COPY hadoop-3.3.4.tar.gz .
RUN tar -xzf hadoop-3.3.4.tar.gz && rm hadoop-3.3.4.tar.gz && \
    mv hadoop-3.3.4 /usr/local/hadoop

# Copy the configuration files
COPY config/hadoop-env.sh /usr/local/hadoop/etc/hadoop/
COPY config/core-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/hdfs-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/mapred-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/yarn-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/workers /usr/local/hadoop/etc/hadoop/

FROM ubuntu:20.04

# Update the package repository and install Java
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y openjdk-8-jdk nano wget sudo && \
    apt-get autoremove

COPY --from=initial /usr/local/hadoop /usr/local/hadoop

# Set the environment variables for Hadoop
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_YARN_HOME $HADOOP_HOME
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop

ENV PATH "$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin"
ENV JAVA_HOME "/usr/lib/jvm/java-8-openjdk/jre"
ENV PATH $PATH:$JAVA_HOME/bin
ENV PS1='\u@\h:\W $ '

# Add a new user and change to new user
# RUN useradd -m hadoopuser && echo "hadoopuser:hadoopuser" | chpasswd && adduser hadoopuser sudo
# RUN usermod -aG sudo hadoopuser && chown hadoopuser:root -R /usr/local/hadoop/
# USER hadoopuser

# Start the Namenode and Datanode
CMD ["/bin/bash"]
