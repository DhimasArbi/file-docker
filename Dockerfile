# Use the Ubuntu base image
FROM ubuntu:20.04

# Update the package repository and install Java
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get upgrade -y &&\
    apt-get install -y locales tar tzdata net-tools apt-utils openjdk-8-jdk git nano wget curl sudo && \
    apt-get autoremove

RUN echo "Asia/Jakarta" > /etc/timezone
RUN ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

VOLUME /data

# Download and extract Hadoop
# RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz && \
COPY hadoop-3.3.4.tar.gz /data/
RUN cd /data && tar -xzf hadoop-3.3.4.tar.gz && rm hadoop-3.3.4.tar.gz && \
    mv hadoop-3.3.4 /usr/local/hadoop

# Set the environment variables for Hadoop
ENV HADOOP_HOME /usr/local/hadoop
RUN echo "PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin" >> /etc/environment
RUN echo JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre" >> /etc/environment
RUN sed -i '1d' /etc/environment

# Add a new user and change to new user
RUN useradd -m hadoopuser && echo "hadoopuser:hadoopuser" | chpasswd && adduser hadoopuser sudo
RUN usermod -aG sudo hadoopuser && chown hadoopuser:root -R /usr/local/hadoop/
USER hadoopuser

# Copy the configuration files
COPY config/hadoop-env.sh /usr/local/hadoop/etc/hadoop/
COPY config/core-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/hdfs-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/mapred-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/yarn-site.xml /usr/local/hadoop/etc/hadoop/

# Start the Namenode and Datanode
CMD ["/bin/bash"]
