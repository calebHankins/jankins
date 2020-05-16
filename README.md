# jankins

![logo](https://raw.githubusercontent.com/calebHankins/jankins/master/img/jankins.png)
[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/calebhankins/jankins.svg?style=flat-square)](https://hub.docker.com/r/calebhankins/jankins/)
[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/calebhankins/jankins.svg?style=flat-square)](https://hub.docker.com/r/calebhankins/jankins/)

*An [image base](https://www.docker.com/) for linting and ci/cd of [Jenkinsfiles](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/) and related [Shared Libraries](https://www.jenkins.io/doc/book/pipeline/shared-libraries/) written in [groovy](https://en.wikipedia.org/wiki/Apache_Groovy).*

# Build

Run these commands from the same folder as this readme. Tweak the Dockerfile to meet your needs.

```bash
docker build --rm -f "Dockerfile" -t jankins .
```

# Run

```bash
# Start the container and run bash interactively
docker run --rm --entrypoint bash -it jankins

# Start container and run Jenkins exposed on host port 8001, with custom env vars set
docker run --rm -p '8081:8080' -it -e JENKINS_EXECUTORS=4 -e JENKINS_USER='admin2' -e JENKINS_PASSWD='welcome1'  jankins
# Exposed as: http://0.0.0.0:8081
```

## Run Params
- The Jenkins env can be customized at runtime via the following [Docker env vars](https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file). Sample values are shown below.

```ini
JENKINS_USER=jankins
JENKINS_PASSWD=jankins
JENKINS_EXECUTORS=1
```

# Related Links & Credits
- [jankins](https://github.com/calebHankins/jankins) logo derived from the [Jenkins project](https://jenkins.io/) artwork, supplied by [@jvanceACX](https://github.com/jvanceACX).
- [Jake Wernette's awesome series on Jenkins Shared Libraries](https://itnext.io/jenkins-shared-libraries-part-1-5ba3d072536a).
- [Jenkins Official Docker hub](https://hub.docker.com/r/jenkins/jenkins).
- [jankins-workspace](https://github.com/calebHankins/jankins-workspace), a containerized workspace for jankins using vscode's remote-container feature.
