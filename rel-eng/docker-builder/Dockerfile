FROM centos:7

RUN yum -y install epel-release && yum -y install mock tito && rm -rf /var/cache/yum/*
RUN useradd -G mock builder

ADD spacewalk-nightly*.cfg /etc/mock/

VOLUME /git
VOLUME /out

USER builder

CMD cd /git/$PACKAGE && tito build --srpm --test | grep "src.rpm" | awk '{print $2}' | xargs /usr/bin/mock -r $DIST --resultdir=/out --rebuild
