# Use the Ubuntu 24.04 base image
FROM ubuntu:24.04

# Update package lists
RUN apt-get update && apt-get upgrade -y

# Install required packages
RUN apt-get install -y \
	influxdb \
	influxdb-client \
	curl \
	wget \
	gnupg \
	net-tools \
	iputils-ping

# Cleanup package cache to reduce image size
RUN apt-get clean

# Expose InfluxDB ports
EXPOSE 8086

# Start InfluxDB service
ENTRYPOINT ["influxd"]
