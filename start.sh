#!/bin/bash
cd /opt/git/libbpf-bootstrap-tc/src/c || exit
git pull
git checkout provaBatch2
make clean
