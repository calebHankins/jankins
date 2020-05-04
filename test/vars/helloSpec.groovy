#!/usr/bin/env groovy

import com.homeaway.devtools.jenkins.testing.JenkinsPipelineSpecification

/* groovylint-disable-next-line ClassJavadoc, ClassName */
class helloSpec extends JenkinsPipelineSpecification {

    /* groovylint-disable-next-line JUnitPublicNonTestMethod */
    Script setup() {
        return loadPipelineScriptForTest('vars/hello.groovy')
    }

    /* groovylint-disable-next-line JUnitPublicProperty */
    Script hello = setup()

    /* groovylint-disable-next-line JUnitPublicNonTestMethod, MethodName */
    void "echos hello world"() {
        when:
        String hello = hello()
        then:
        hello == 'Hello, world!'
    }

}
