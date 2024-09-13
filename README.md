Podman turnkey container where you can test access to the influxdb server using
bridge C libraries.

To build the image, just run:
```bash
$ podman build --platform linux/amd64 -t podman-influxdb .
```

Once you have the image, you can run the container:
```bash
$ podman run -d --rm --name influxtest -it localhost/podman-influxdb bash
```

```bash
$ podman run -d --rm --name influxtest -v ../libbpf-bootstrap-tc:/opt/shared/libbpf-bootstrap-tc -it --privileged --ulimit memlock=-1 localhost/podman-influxdb bash
```

```bash
$ podman run -d --rm --name influxtest -it --privileged --ulimit memlock=-1 localhost/podman-influxdb bash
```


It is possible to enter the running container:
```bash
$ podman exec -it libbpf1 bash
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

Query to can visualize the flows in chronograph ```SELECT "value" FROM "tc_db"."autogen"."rate" WHERE time > now() - 1h```

To create the ipv6 network used in the compose: ``` podman network create --subnet 10.89.0.0/24 --gateway 10.89.0.1 --ipv6 --subnet fd00:dead:beef::/48 --gateway fd00:dead:beef::1 my_ipv6_network ```

# libbpf2 ipv4 addr: 10.89.0.20
# libbpf1 ipv4 addr: 10.89.0.10

To can ping the container libbpf1 to libbpf2 using ipv4 it's mandatory to specify the ipv4 address, for example ``` ping 10.89.0.20 ```

To can ping the container libbpf1 to libbpf2 using ipv6 you just need to use ``` ping libbpf2 ```