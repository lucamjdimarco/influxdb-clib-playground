# Use the Ubuntu 24.04 base image
FROM ubuntu:24.04

# Update package lists
RUN apt-get update

# Install any packages or dependencies here
RUN apt-get install -y \
	curl \
	wget \
	lsb-release \
	software-properties-common \
	pkg-config \
	binutils-dev \
	libcap-dev \
	libelf-dev \
	gcc-multilib \
	gpg \
	vim \
	git \
	libboost-all-dev \
	g++ \
	cmake \
	libssl-dev \
	libcurl4-openssl-dev \
	influxdb \
	influxdb-client \
	systemd \
	init \
	iproute2 \
	net-tools

# install latest llvm for ebpf
RUN mkdir -p /opt/llvm && cd /opt/llvm && \
	wget https://apt.llvm.org/llvm.sh && \
	chmod +x llvm.sh && \
	./llvm.sh all && \
	wget https://raw.githubusercontent.com/ShangjinTang/dotfiles/05ef87daae29475244c276db5d406b58c52be445/linux/ubuntu/22.04/bin/update-alternatives-clang && \
	chmod +x update-alternatives-clang && \
	sed -i 's/sudo//g' update-alternatives-clang && \
	./update-alternatives-clang

RUN mkdir -p /opt/git

# influxdb libraries rely on cpr library;
# compile cpr
RUN cd /opt/git && \
	git clone https://github.com/libcpr/cpr.git && \
	mkdir -p /opt/git/cpr/build
RUN cd /opt/git/cpr/build && \
	cmake .. -DCPR_USE_SYSTEM_CURL=ON
RUN cd /opt/git/cpr/build && \
	cmake --build . --parallel && \
	cmake --install .

# update cache for dynamic libraries
RUN ldconfig

# compile influxdb-cxx library
RUN cd /opt/git && \
	git clone https://github.com/offa/influxdb-cxx && \
	mkdir -p /opt/git/influxdb-cxx/build
RUN cd /opt/git/influxdb-cxx/build && \
	cmake .. -DINFLUXCXX_TESTING:BOOL=OFF && \
	make -j$(nproc) install

# update cache for dynamic libraries
RUN ldconfig

# compile test project for checking c-influxdb bridge
RUN cd /opt/git && \
	git clone https://github.com/lucamjdimarco/c-influxdb-example.git

# Cleanup package cache to reduce image size
RUN apt-get clean

ENTRYPOINT ["/sbin/init"]
