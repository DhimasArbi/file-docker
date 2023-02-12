# Use Alpine Linux as the base image for building Hadoop
FROM alpine:3.12 as build

# Install Java
RUN apk add openjdk8-jre

# Download and extract Hadoop
RUN wget http://mirror.cogentco.com/pub/apache/hadoop/common/hadoop-3.3.0/hadoop-3.3.0.tar.gz
RUN tar xvf hadoop-3.3.0.tar.gz

# Use Ubuntu as the base image for running Hadoop
FROM ubuntu:20.04

# Copy Hadoop from the build stage
COPY --from=build /hadoop-3.3.0 /hadoop

# Set environment variables
ENV HADOOP_HOME /hadoop
ENV PATH $PATH:$HADOOP_HOME/bin

# Set JAVA_HOME
RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk' >> /hadoop/etc/hadoop/hadoop-env.sh

# Verify that Hadoop is working correctly
RUN hadoop version

# Set the working directory to /hadoop
WORKDIR /hadoop