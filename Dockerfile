FROM debian:wheezy
MAINTAINER Eduardo Cardoso

RUN apt-get update && apt-get install -y build-essential git libfuse-dev libcurl4-openssl-dev libxml2-dev mime-support automake libtool
RUN git clone https://github.com/s3fs-fuse/s3fs-fuse /s3fs

RUN cd /s3fs && ./autogen.sh && ./configure --prefix=/usr --with-openssl && make && make install
RUN rm -rf /s3fs
RUN mkdir /s3bucket

RUN apt-get install -y nfs-server nfs-common
RUN echo "/s3bucket		*(rw,sync,fsid=0,crossmnt,no_subtree_check,no_root_squash)" >> /etc/exports

ADD files/run.sh /opt/bin/run.sh
ADD files/services /etc/services
ADD files/nfs-kernel-server /etc/default/nfs-kernel-server
ADD files/nfs-common /etc/default/nfs-common

EXPOSE 111/udp 111/tcp 2049/udp 2049/tcp 32765/udp 32765/tcp 32766/udp 32766/tcp 32767/udp 32767/tcp 32768/udp 32768/tcp

CMD /opt/bin/run.sh
