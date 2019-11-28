FROM ubuntu:18.04
LABEL MAINTAINER @aruizca - Angel Ruiz

ENV JAVA_HOME /opt/jre
ENV PATH $JAVA_HOME/bin:$PATH
# https://confluence.atlassian.com/adminjiraserver/important-directories-and-files-938847744.html
ENV JIRA_HOME          /var/atlassian/application-data/jira
ENV JIRA_INSTALL_DIR   /opt/atlassian/jira

ARG JIRA_VERSION
ARG JAVA_VERSION

# Install some utilse
RUN apt-get update \
&& apt-get install -yq wget curl bash jq ttf-dejavu ca-certificates tzdata locales locales-all iproute2 \
&& update-ca-certificates \
&& rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

# Use jabba JVM Manger to install Oracle JRE 1.8
RUN curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | JABBA_COMMAND="install ${JAVA_VERSION} -o ${JAVA_HOME}" bash

# If no jira version provided via command line argument, the last available version will be installed

# Expose HTTP, Synchrony ports and Debug ports
EXPOSE 8080 8081 5005

WORKDIR $JIRA_HOME

RUN mkdir scripts
COPY entrypoint.sh /scripts/entrypoint.sh

# Download required Jira version
RUN [ -n "${JIRA_VERSION}" ] || export JIRA_VERSION=$(curl -s https://marketplace.atlassian.com/rest/2/applications/jira/versions/latest | jq -r '.version') \
    && export DOWNLOAD_URL="https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${JIRA_VERSION}.tar.gz" \
    && mkdir -p                          ${JIRA_INSTALL_DIR} \
    && curl -L                           ${DOWNLOAD_URL} | tar -xz --strip-components=1 -C "$JIRA_INSTALL_DIR"

# Perform settings modifications
RUN sed -i -e 's/-Xms\([0-9]\+[kmg]\) -Xmx\([0-9]\+[kmg]\)/-Xms\${JVM_MINIMUM_MEMORY:=\1} -Xmx\${JVM_MAXIMUM_MEMORY:=\2} \${JVM_SUPPORT_RECOMMENDED_ARGS} -jira.home=\${JIRA_HOME} -Dsynchrony.proxy.healthcheck.disabled=true/g' ${JIRA_INSTALL_DIR}/bin/setenv.sh \
    && sed -i -e 's/<Context path=""/<Context path="\/jira"/g' ${JIRA_INSTALL_DIR}/conf/server.xml \
    && sed -i -e 's/\${jira.context.path}/\/jira/g' ${JIRA_INSTALL_DIR}/conf/server.xml

CMD ["/scripts/entrypoint.sh", "-fg"]