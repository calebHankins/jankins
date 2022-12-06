FROM jenkins/jenkins:lts

USER root

# Install Node.js & npm
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt install -y nodejs
RUN npm install -g npm
RUN echo NODE_ENV:$NODE_ENV
RUN node --version && npm --version

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
# RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/pipeline.txt

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
COPY ./src ./src
COPY ./test ./test
RUN mvn clean test

# Run an ascending order of groovy linting.
# todo, condense these down to one run for performance boost.
# @info Currently these flags on the cli are mutually exclusive and don't include the other levels
# @info Currently the --output is empty if you give it a file path (ext only works though)
# RUN npm-groovy-lint --failonerror
# RUN npm-groovy-lint --failonwarning
# RUN npm-groovy-lint --failoninfo
# @a For now, going to port the results to json and do a quick check in a custom node script
# RUN mkdir -p ./logs && npm-groovy-lint --output 'json' > './logs/groovyLintResults.json'
# @info The linter will print 1 or more lines of non-json text, adding a grep to only save lines starting with a '{'
COPY ./scripts ./scripts
COPY ./.groovylintrc.json ./.groovylintrc.json
RUN mkdir -p ./logs && npm-groovy-lint --output 'json' | grep '^{' > './logs/groovyLintResults.json'
RUN cat './logs/groovyLintResults.json'
RUN node ./scripts/checkGroovyLintResults.js

# todo, roll a custom bootstrap around the entrypoint, only spin up jenkins app if we have pipelines to validate
# ENTRYPOINT [ "bash" ]
LABEL name=jankins maintainer="Caleb Hankins <caleb.hankins@acxiom.com>"
