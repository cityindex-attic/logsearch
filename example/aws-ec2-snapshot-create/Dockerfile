FROM ubuntu:precise
ADD . /docker
WORKDIR /docker
RUN ( nc -zw 8 172.17.42.1 3142 && echo 'Acquire::http { Proxy "http://172.17.42.1:3142"; };' > /etc/apt/apt.conf.d/01proxy ) || true
RUN ./bin/provision
ENTRYPOINT [ "./bin/run" ]
