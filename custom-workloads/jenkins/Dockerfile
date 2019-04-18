
# Use jenkins:2.60.3 as base image 
FROM jenkins:2.60.3

# Change user to root
USER root

# Install "jq" module
RUN apt-get update && apt-get install -y \
        python-pip \
        autoconf \
        automake \
        build-essential \
        libtool \
        python-dev \
        jq

# Install latest version of Jenkins Job builder
RUN pip install --user jenkins-job-builder

# Copy jjb directory to /var/jjb
COPY jjb /var/jjb

# Copy start-jenkins-load.sh to /var/jjb
COPY script/start-jenkins-load.sh /var/jjb

# Add execute permission to jenkins-jobs
RUN ["chmod", "+x", "/root/.local/bin/jenkins-jobs"]

# Add execute permissions to copied files on /var/jjb
RUN ["chmod", "-R", "+x", "/var/jjb"]

# Set working directory to /var/jjb
WORKDIR /var/jjb
