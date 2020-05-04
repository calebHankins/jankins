FROM jenkins/jenkins:lts

USER root

# Install Node.js
RUN apt-get update && apt-get install -y wget tar
RUN wget https://nodejs.org/dist/v12.16.1/node-v12.16.1-linux-x64.tar.gz
RUN tar --strip-components 1 -xzvf node-v* -C /usr/local

# Install groovy
RUN apt-get install -y groovy

# Install groovy-lint globally
RUN npm install -g npm-groovy-lint

# Install Maven
RUN apt-get install -y maven

# Drop back to the regular jenkins user
USER jenkins

# Install extensions needed for pipeline linting
COPY ./jenkins/config/pipeline.txt /usr/share/jenkins/ref/pipeline.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/pipeline.txt

# Install service account for pipeline linting
ENV JENKINS_USER='jankins' JENKINS_PASSWD='jankins'
ENV JAVA_OPTS=-Djenkins.install.runSetupWizard=false
COPY ./jenkins/config/security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy

# Set number of executors
ENV JENKINS_EXECUTORS=1
COPY ./jenkins/config/executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy

USER root

# Install dependencies listed in pom and perform sanity tests
WORKDIR /usr/src/jankins
COPY ./pom.xml ./
RUN mvn clean install

# Copy Groovy Samples and Run sanity tests
COPY ./vars ./vars
COPY ./test ./test
RUN mvn clean test

# todo, roll a custom bootstrap around the entrypoint, only spin up jenkins app if we have pipelines to validate
# ENTRYPOINT [ "bash" ]
LABEL name=jankins maintainer="Caleb Hankins <caleb.hankins@acxiom.com>"
