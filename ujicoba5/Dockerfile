# Use the Alpine Linux base image
FROM alpine:3.12

# Update the package repository and install Java
RUN apk update && apk add openjdk8-jre nano wget sudo

# Download and extract Hadoop
RUN cd ..
COPY hadoop-3.3.4.tar.gz .
RUN tar -xzf hadoop-3.3.4.tar.gz && rm hadoop-3.3.4.tar.gz && \
    mv hadoop-3.3.4 /usr/local/hadoop

# Set the environment variables for Hadoop
ENV HADOOP_HOME /usr/local/hadoop
RUN echo "PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin" >> /etc/profile
RUN echo 'JAVA_HOME="/usr/lib/jvm/java-8-openjdk"' >> /etc/profile

# Add a new user and change to new user
RUN adduser -D hadoopuser && echo "hadoopuser:hadoopuser" | chpasswd && adduser hadoopuser sudo
RUN chown -R hadoopuser:root /usr/local/hadoop/
USER hadoopuser

# Copy the configuration files
RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk' >> /usr/local/hadoop/etc/hadoop//hadoop-env.sh
# COPY config/hadoop-env.sh /usr/local/hadoop/etc/hadoop/
COPY config/core-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/hdfs-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/mapred-site.xml /usr/local/hadoop/etc/hadoop/
COPY config/yarn-site.xml /usr/local/hadoop/etc/hadoop/

# Start the Namenode and Datanode
CMD ["/bin/sh"]
