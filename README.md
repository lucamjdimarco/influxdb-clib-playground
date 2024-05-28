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
