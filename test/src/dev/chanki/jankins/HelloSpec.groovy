#!/usr/bin/env groovy

import com.homeaway.devtools.jenkins.testing.JenkinsPipelineSpecification

import dev.chanki.jankins.Hello

class HelloSpec extends JenkinsPipelineSpecification {

    Object hello = new Hello()

    /* groovylint-disable-next-line JUnitPublicNonTestMethod, MethodName */
    void "echos hello world"() {
        when:
        String hello = hello.exec()
        then:
        hello == 'Hello, world!'
    }

}
