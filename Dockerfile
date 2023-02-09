# Use the Ubuntu base image
FROM ubuntu:20.04

# Update the package repository and install Java
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME environment variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Download and extract Hadoop
RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz && \
    tar -xzf hadoop-3.3.4.tar.gz && \
    mv hadoop-3.3.4 /usr/local/hadoop && \
    rm hadoop-3.3.4.tar.gz

# Set HADOOP_HOME environment variable
ENV HADOOP_HOME /usr/local/hadoop

# Add Hadoop bin directory to PATH
ENV PATH $PATH:$HADOOP_HOME/bin

# Copy the configuration files
COPY config/hadoop-env.sh $HADOOP_HOME/etc/hadoop/
COPY config/core-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/mapred-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/yarn-site.xml $HADOOP_HOME/etc/hadoop/

# Format the Namenode
RUN echo "Y" | hdfs namenode -format

# Start the Namenode and Datanode
CMD ["/usr/local/hadoop/sbin/start-dfs.sh", "&&", "/usr/local/hadoop/sbin/start-yarn.sh"]
