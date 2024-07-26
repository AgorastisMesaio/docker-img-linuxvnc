# Dockerfile to build custom VNC Server
#
#

# Based on: https://hub.docker.com/r/dorowu/ubuntu-desktop-lxde-vnc/
#
# Create a Ubuntu based VNC Server
#
FROM dorowu/ubuntu-desktop-lxde-vnc:latest

# Adding some net tools so we can use the later (i.e. ping)
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E88979FB9B30ACF2
RUN apt-get update && apt-get install -y \
    net-tools \
    iputils-ping \
    iproute2
