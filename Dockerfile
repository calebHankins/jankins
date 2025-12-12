FROM jenkins/jenkins:2.479.1

USER root

# Since we're pinning to bullseye for now due to dome downstream issues, do upgrade as soon as we start
RUN apt update || true; apt upgrade || true;

# Install Node.js & npm
# @see: https://github.com/nodesource/distributions#debian-versions
RUN apt update && \
    apt install -y ca-certificates curl gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
# @see: https://github.com/nodesource/distributions/issues/1601
RUN echo "Package: nodejs" >> /etc/apt/preferences.d/preferences \
    && echo "Pin: origin deb.nodesource.com" >> /etc/apt/preferences.d/preferences \
    && echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/preferences
RUN apt update
RUN apt install -y nodejs
# RUN apt install -y npm
# RUN npm install -g npm
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
# @see: https://community.jenkins.io/t/how-to-generate-a-docker-with-the-desired-plugins-installed/3453
COPY ./jenkins/config/pipeline.txt /usr/share/jenkins/ref/pipeline.txt
RUN jenkins-plugin-cli --verbose --plugin-file /usr/share/jenkins/ref/pipeline.txt || \
    /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/pipeline.txt

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
RUN mvn clean install -DskipTests

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
# npm-groovy-lint doesn't support arm64
RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then mkdir -p ./logs && npm-groovy-lint --output 'json' | grep '^{' > './logs/groovyLintResults.json'; fi
RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then cat './logs/groovyLintResults.json'; fi
RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then node ./scripts/checkGroovyLintResults.js; fi

# todo, roll a custom bootstrap around the entrypoint, only spin up jenkins app if we have pipelines to validate
# ENTRYPOINT [ "bash" ]
LABEL name=jankins maintainer="Caleb Hankins <caleb.hankins@acxiom.com>"
