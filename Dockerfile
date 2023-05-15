FROM ubuntu:20.04
MAINTAINER Mike Cabalin <mike.cabalin@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive


# Update and Upgrade Ubuntu
RUN     apt-get update -y && \
        apt-get upgrade -y && apt-get install sudo -y

# Install dependencies
RUN apt-get install -y bind9 bind9utils ssh netcat-openbsd sudo libidn11 libpcre3 libgmp10 libexpat1 libstdc++6 libperl5.26 libaio1 resolvconf unzip pax sysstat sqlite3 dnsutils iputils-ping w3m gnupg less lsb-release rsyslog net-tools $

# Configure Timezone
RUN echo "tzdata tzdata/Areas select Asia\ntzdata tzdata/Zones/Asia select Manila" > /tmp/tz ; debconf-set-selections /tmp/tz; rm /etc/localtime /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

# Add LC_ALL on .bashrc
RUN echo 'export LC_ALL="en_US.UTF-8"' >> /root/.bashrc
RUN locale-gen en_US.UTF-8

# Download dns-auto.sh
RUN curl -k https://raw.githubusercontent.com/aeonmike/zimbra-certdeploy/master/dns.sh > /srv/dns.sh
RUN chmod +x /srv/dns.sh

# Entrypoint
ENTRYPOINT /services.sh && /bin/bash
