# Use the Ubuntu base image
FROM ubuntu:20.04

# Update the package repository and install Java
RUN echo "Asia/Jakarta" > /etc/timezone
RUN ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

RUN apt-get update && apt-get upgrade -y &&\
    apt-get install -y locales tar net-tools apt-utils openjdk-8-jdk git nano wget curl && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Download and extract Hadoop
RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz && \
    tar -xzf hadoop-3.3.4.tar.gz && \
    mv hadoop-3.3.4 /usr/local/hadoop && \
    rm hadoop-3.3.4.tar.gz

# Make new User
RUN useradd -m -p 1121 hadoopuser
RUN usermod -aG hadoopuser hadoopuser
RUN chown hadoopuser:root -R /usr/local/hadoop/
RUN adduser hadoopuser sudo

# Set HADOOP_HOME environment variable
ENV HADOOP_HOME /usr/local/hadoop

# Add Hadoop bin directory to PATH
RUN echo "PATH=$PATH:/usr/local/hadoop/sbin" >> /etc/environment
RUN echo "JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre" >> /etc/environment

# Copy the configuration files
COPY config/hadoop-env.sh $HADOOP_HOME/etc/hadoop/
COPY config/core-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/mapred-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/yarn-site.xml $HADOOP_HOME/etc/hadoop/

# Format the Namenode
RUN echo "Y" | hdfs namenode -format

# Start the Namenode and Datanode
CMD ["/bin/bash"]
