FROM centos:centos8

ONBUILD RUN yum clean all && yum update -y

RUN yum clean all && \
yum update -y && \
yum install -y dstat \
                lsof \
                mailx \
                mtr \
                nc \
                rsync \
                strace \
                traceroute \
                unzip \
                wget \
                passwd \
                yum-utils \
                zip && \
    mkdir /dist && \
    ln -sf /usr/share/zoneinfo/US/Pacific /etc/localtime && \
    yum clean all

#ENV LANG=en_US.UTF-8 TERM=xterm-256color

#RUN useradd -ms /bin/bash distro

CMD [ "/bin/bash" ]