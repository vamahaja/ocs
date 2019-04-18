
# Use mongodb version 4.0.6 as base
FROM mongo:4.0.6

# Update base image
RUN apt-get update -y

# Install openjdk-8
RUN apt-get install openjdk-8-jdk -y

# Install python
RUN apt-get install python -y

# Set environment varible ycsb_version
ENV ycsb_version=0.13.0

# Download ycsb build from https://github.com/brianfrankcooper/YCSB/releases
# and copy in the same directory
ADD ycsb-0.13.0.tar.gz /

# Move ycsb directory into /ycsb directory
# change ycsb-0.13.0 directory name as per version
RUN mv /ycsb-0.13.0 /ycsb

# Copy script for starting ycsb load
COPY start-ycsb-load.sh /ycsb

# Change user to 'root' for setting permission on script
USER root

# Add executable permission to script
RUN ["chmod", "+x", "/ycsb/probe-liveness.sh"]

# set working directory as /ycsb
WORKDIR /ycsb
