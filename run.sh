#!/bin/bash
/etc/init.d/bind9 start
cp /etc/resolv.conf /tmp/r \
  && echo 'nameserver 127.0.0.1' > /etc/resolv.conf \
  && cat /tmp/r >> /etc/resolv.conf

/etc/init.d/slapd start
/etc/init.d/krb5-kdc start
/etc/init.d/krb5-admin-server start

sleep infinity
