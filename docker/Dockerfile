FROM    alpine

ENV     RUNDECK_VERSION=2.11.4
ENV     RDECK_BASE=/etc/rundeck
ENV     RDECK_JAR=$RDECK_BASE/app.jar
ENV     PATH=$PATH:$RDECK_BASE/tools/bin

ADD     http://dl.bintray.com/rundeck/rundeck-maven/rundeck-launcher-2.11.4.jar $RDECK_JAR
RUN     apk add --update openjdk8-jre bash curl ca-certificates openssh-client && \
        mkdir -p $RDECK_BASE && \
        rm -Rf /var/cache/apk/*

COPY    run.sh /bin/rundeck

# Keystore
RUN     mkdir -p /var/lib/rundeck/.ssh
RUN     mkdir -p $RDECK_BASE/ssl

# Active Directory integration
COPY    jaas-activedirectory.conf $RDECK_BASE/server/config/jaas-activedirectory.conf
COPY    web.xml $RDECK_BASE/server/exp/webapp/WEB-INF/web.xml

# Set ACLs
COPY    admin.aclpolicy $RDECK_BASE/etc/admin.aclpolicy

# install dir
# ssh-keys
# logs
VOLUME  [ "$RDECK_BASE", "/var/lib/rundeck/.ssh", "$RDECK_BASE/server/logs" ]

CMD     rundeck
