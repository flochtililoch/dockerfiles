FROM resin/armv7hf-debian
MAINTAINER flochtililoch
ENV REFRESHED_ON 2017-01-04

RUN \
  # Update system
  apt-get update && \
  apt-get upgrade -y

RUN \
  # Install LIRC
  apt-get install lirc -y

RUN \
  # Create PID directory
  mkdir -p /var/run/lirc

CMD \
  # Run LIRC
  /usr/sbin/lircd \
    --driver=default \
    --device=/dev/lirc0 \
    --nodaemon
