# Use the Ubuntu base image
FROM ubuntu:20.04 as initial

# Update the package repository and install Java
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y openjdk-8-jdk nano wget sudo && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Download and extract Hadoop
# RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz && \
COPY hadoop-3.3.4.tar.gz /data/
RUN cd /data && tar -xzf hadoop-3.3.4.tar.gz && rm hadoop-3.3.4.tar.gz && \
    mv hadoop-3.3.4 /usr/local/hadoop

FROM ubuntu:20.04
COPY --from=initial /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/java-8-openjdk-amd64
COPY --from=initial  /usr/local/hadoop /usr/local/hadoop

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
RUN echo JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh
# COPY config/hadoop-env.sh /usr/local/hadoop/etc/hadoop/
COPY config/core-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/hdfs-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/mapred-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/yarn-site.xml /usr/local/hadoop/etc/hadoop/

# Start the Namenode and Datanode
CMD ["/bin/bash"]
