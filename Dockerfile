FROM ubuntu:18.04

RUN apt-get update && apt-get -y upgrade && apt-get -y install python3 debconf-utils expect

# DNS
RUN apt-get -y install bind9

COPY db.dir /etc/bind/db.dir
COPY db.127 /etc/bind/db.127
COPY named.conf.local /etc/bind/named.conf.local

EXPOSE 53/udp
VOLUME /etc/bind

# LDAP
COPY slapd-selections /tmp/slapd-selections
RUN debconf-set-selections /tmp/slapd-selections
COPY setup.ldif /tmp/setup.ldif
RUN apt-get -y install slapd openldap-utils
RUN /etc/init.d/slapd start && ldapmodify -H 'ldapi:///' -Y EXTERNAL -f /tmp/setup.ldif && /etc/init.d/slapd stop

EXPOSE 389
VOLUME /var/lib/ldap

# Kerberos
COPY krb-selections /tmp/krb-selections
RUN debconf-set-selections /tmp/krb-selections
RUN apt-get -y install krb5-kdc krb5-admin-server libsasl2-modules-gssapi-mit
COPY krb-db.expect /tmp/krb-db.expect
RUN expect -f /tmp/krb-db.expect
COPY krb5.conf /etc/krb5.conf
RUN kadmin.local -q "addprinc -pw password admin@MY.DIR" \
      && kadmin.local -q "addprinc -randkey ldap/localhost" \
      && kadmin.local -q "addprinc -randkey ldap/my.dir" \
      && kadmin.local -q "ktadd -k /etc/ldap/ldap.keytab -glob ldap/*" \
      && chown openldap:openldap /etc/ldap/ldap.keytab

EXPOSE 88
EXPOSE 88/udp
EXPOSE 464
EXPOSE 464/udp
EXPOSE 749
EXPOSE 750/udp
VOLUME /var/lib/krb5kdc

# LDAP + kerberos
COPY slapd-defaults /etc/default/slapd

# startup
COPY run.sh /run.sh
RUN chmod u+x /run.sh

CMD ["/run.sh"]
