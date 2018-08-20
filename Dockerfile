FROM debian:jessie AS build-cobol
RUN apt-get update && apt-get -y install open-cobol && \
    mkdir -p /usr/src/cobol
WORKDIR /usr/src/cobol
COPY cobol-hello-world /usr/src/cobol
RUN cobc -static -x -free cow.cbl `ls -d controllers/*` -o the.cow

FROM debian:jessie AS build-klange
RUN apt-get update && apt-get -y install gcc make && \
    mkdir -p /usr/src/klange
WORKDIR /usr/src/klange
COPY klange /usr/src/klange
RUN make

FROM debian:jessie-slim

RUN apt-get update && apt-get -y install libcob1 && \
    apt-get -y autoremove && \
    echo 'Yes, do as I say!' | apt-get remove -y --force-yes --purge \
    passwd python2.7 mount sysv-rc sysvinit-utils udev e2fslibs e2fsprogs login python \
    gzip bsdutils apt || \
    rm -rf /var/cache/apt /usr/share /usr/lib/python2.7 /sbin

RUN mkdir -p /var/www
COPY --from=build-cobol /usr/src/cobol/ /var/www
COPY --from=build-klange /usr/src/klange/cgiserver /usr/bin/cgiserver
WORKDIR /var/www

EXPOSE 3000
CMD ["cgiserver"]
