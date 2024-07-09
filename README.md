Podman turnkey container where you can test access to the influxdb server using
bridge C libraries.

To build the image, just run:
```bash
$ podman build -t podman-influxdb .
```

Once you have the image, you can run the container:
```bash
$ podman run -d --rm --name influxtest -it localhost/podman-influxdb bash
```

```bash
$ podman run -d --rm --name influxtest -v ../libbpf-bootstrap-tc:/opt/shared/libbpf-bootstrap-tc -it --privileged --ulimit memlock=-1 localhost/podman-influxdb bash
```


It is possible to enter the running container:
```bash
$ podman exec -it influxtest bash
```

To interact with influxdb through the bridging libraries in C, use the test C
program in
```bash
/opt/git/c-influxdb-example
```

The program must be compiled. When run, the program writes a point to the
```temperature_db``` database in the local influxdb.

To stop the container: ```podman stop influxtest```

```make -j6 CFLAGS_EXTRA="-DCLASS=1"```


tc filter del dev eth0 ingress