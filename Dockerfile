# Use the Ubuntu 24.04 base image
FROM --platform=linux/amd64 ubuntu:24.04

# Update package lists
RUN apt-get update && apt-get upgrade -y

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
	systemd \
	init \
	iproute2 \
	net-tools \
	iputils-ping \
	gnupg \
	gdb \
	python3-venv \
	python3-bpfcc \
	linux-headers-generic \
	python3-pip

# Setup Python virtual environment and install dependencies
RUN python3 -m venv /myenv && \
    /myenv/bin/pip install requests redis

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
	cd cpr && \
	git checkout 3aa81a6 && \
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

# Clone the libbpf-bootstrap-tc repository and checkout the influxDB-test branch
RUN cd /opt/git && \
	git clone --recurse-submodules https://github.com/lucamjdimarco/libbpf-bootstrap-tc.git && \
	cd libbpf-bootstrap-tc && \
	git submodule update --init --recursive && \
	git checkout testDistributed

# Compile and install bpftool
RUN cd /opt/git/libbpf-bootstrap-tc/bpftool/src && make install

# Cleanup package cache to reduce image size
RUN apt-get clean

# Configure RLIMIT_MEMLOCK for BPF programs
#RUN ulimit -l unlimited

ENTRYPOINT ["/sbin/init"]