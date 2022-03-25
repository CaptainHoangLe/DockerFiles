FROM oraclelinux:8

ARG TOMCAT_VERSION=9.0.58 \
    APEX_DOWNLOAD_LINK='https://download.oracle.com/otn_software/apex/apex-latest.zip' \
    ORDS_DOWNLOAD_LINK='https://download.oracle.com/otn_software/java/ords/ords-latest.zip'

ENV JAVA_OPTS="-Djava.security.egd=file:///dev/urandom" \
    CATALINA_BASE=/opt/tomcat/latest \
    CATALINA_HOME=/opt/tomcat/latest \
    CATALINA_PID=/opt/tomcat/latest/temp/tomcat.pid \
    CATALINA_OPTS="-Xms1024M -Xmx2048M -server -XX:+UseParallelGC"

ENV DB_HOSTNAME="localhost" \
    DB_PORT="1521" \
    DB_SERVICE="pdb" \
    APEX_PUBLIC_USER_PASSWORD="public" \
    APEX_TABLESPACE="SYSAUX" \
    TEMP_TABLESPACE="TEMP" \
    APEX_LISTENER_PASSWORD="public" \
    APEX_REST_PASSWORD="public" \
    APEX_PUBLIC_PASSWORD="public" \
    DBA_USER='sys' \
    DBA_PASSWORD="Admin123" \
    APEX_ADMIN_PASSWORD='P@ssWord123!'

# Install java 11
RUN dnf update -y && \
    dnf -y install java-11-openjdk-headless which tar &&\
    echo "JAVA_HOME=$(readlink -f $(which java)| rev | cut -d'/' -f3- | rev)" >> /etc/environment &&\
    . /etc/environment

# Install utility
RUN dnf install -y which wget unzip oracle-instantclient-release-el8 && \
    dnf install -y oracle-instantclient-sqlplus

WORKDIR /opt

RUN wget ${APEX_DOWNLOAD_LINK} &&\
    wget ${ORDS_DOWNLOAD_LINK} &&\
    unzip apex*.zip && unzip ords*.zip -d ords &&\
    rm -rf *.zip

# Install tomcat

RUN mkdir /opt/tomcat && cd /opt/tomcat &&\
    wget "https://dlcdn.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" &&\
    tar -xzvf apache-tomcat-${TOMCAT_VERSION}.tar.gz &&\
    ln -s /opt/tomcat/apache-tomcat-${TOMCAT_VERSION}/ ${CATALINA_HOME}

# Config tomcat
# 

COPY ords_params.properties /opt/ords/params/
COPY scripts/entrypoint.sh /opt/

RUN dnf remove -y wget unzip tar which && \
    rm -rf /var/cache/dnf

RUN chmod +x /opt/entrypoint.sh && chmod +x ${CATALINA_HOME}/bin/*.sh

EXPOSE 8080

ENTRYPOINT [ "/opt/entrypoint.sh" ]
