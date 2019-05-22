# docker-my-dir

**Work In Progress**

This is a self-contained LDAP + Kerberos + DNS Docker image. *For testing
purposes only* this makes no effort to be secure or highly available.

To allow Kerberos and RDNS to work nicely with minimal client config, a second,
known IP address (127.0.0.3) must be configured on your loopback interface. All
ports published by the container should be mapped on this address, and then the
address should be added as a DNS server. The internal DNS server is configured
to reference this IP.

MacOS:
```
ifconfig lo0 alias 127.0.0.3 255.0.0.0
```

Linux:
```
ip addr add 127.0.0.3/8 dev lo
```

Running image:
```
docker build . -t mydir
docker run -p 127.0.0.3:53:53/udp \
           -p 127.0.0.3:389:389 \
           -p 127.0.0.3:88:88 \
           -p 127.0.0.3:88:88/udp \
           -p 127.0.0.3:464:464 \
           -p 127.0.0.3:464:464/udp \
           -p 127.0.0.3:749:749 \
           -p 127.0.0.3:750:750/udp \
           -d --name test0 mydir
```

A planned addition is a small HTTP service for adding and removing users and
changing passwords.
