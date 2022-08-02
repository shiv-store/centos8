FROM centos:centos8

ONBUILD RUN yum clean all && yum update -y
WORKDIR /opt
RUN cd /etc/yum.repos.d/ && sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
        sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
        yum update -y
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

COPY kubernetes.repo /etc/yum.repos.d/
RUN yum install -y kubectl
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
RUN mv /tmp/eksctl /usr/local/bin
RUN curl -fsSL -o helm-v3.7.1-linux-amd64.tar.gz https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz
RUN tar -zxvf helm-v3.7.1-linux-amd64.tar.gz

Run mv linux-amd64/helm /usr/local/bin/helm

#RUN yum install epel-release -y
#RUN yum install ansible -y
#RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
#RUN unzip awscliv2.zip
#RUN ./aws/install

#ADD http://source.file/url  /destination/path

#ENV LANG=en_US.UTF-8 TERM=xterm-256color

#RUN useradd -ms /bin/bash distro

CMD [ "/bin/bash" ]