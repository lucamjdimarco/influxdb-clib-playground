#!/bin/bash

cd /opt/git/libbpf-bootstrap-tc/src/c || exit

# Aggiorna e installa pacchetti
apt update
apt install -y python3-venv python3-bpfcc linux-headers-generic python3-pip

# Configura l'ambiente virtuale
python3 -m venv myenv
source myenv/bin/activate
pip install bcc numba pytest redis

# Configura il link per libLLVM e aggiorna la cache
ln -sf /lib/x86_64-linux-gnu/libLLVM-18.so.18.1 /lib/x86_64-linux-gnu/libLLVM.so.18.1
ldconfig

# Verifica importazione di libLLVM
python3 -c "import ctypes; ctypes.CDLL('libLLVM.so.18.1')"

# Configura moduli
# ln -s /lib/modules/6.8.0-48-generic /lib/modules/6.8.11-300.fc40.aarch64
ln -s /lib/modules/6.8.0-48-generic /lib/modules/5.15.146.1-microsoft-standard-WSL2

# Imposta PYTHONPATH
export PYTHONPATH="/opt/git/libbpf-bootstrap-tc/src/c/myenv/lib/python3.12/site-packages:$PYTHONPATH"
# PYTHONPATH="/opt/git/libbpf-bootstrap-tc/src/c/myenv/lib/python3.12/site-packages:$PYTHONPATH"
