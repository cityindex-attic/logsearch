FROM ubuntu:precise
ADD . /docker
WORKDIR /docker
#RUN echo "Acquire::http { Proxy \"http://10.0.3.1:3142\"; };" | tee -a /etc/apt/apt.conf.d/01proxy > /dev/null
RUN ./bin/provision.sh
ENTRYPOINT [ "./bin/run.sh" ]
