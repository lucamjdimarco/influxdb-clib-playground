#!/bin/bash
# Aggiorna la lista dei pacchetti
sudo apt update
apt install -y python3-venv python3-bpfcc linux-headers-generic python3-pip
python3 -m venv myenv
source myenv/bin/activate
pip install redis requests

apt install -y libhiredis-dev

apt install -y iperf3

cd /opt/git/libbpf-bootstrap-tc/src/c || exit
git pull
git checkout provaBatch2
make clean
