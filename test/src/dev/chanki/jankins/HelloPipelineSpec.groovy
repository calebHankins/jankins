#!/usr/bin/env groovy
/* groovylint-disable ClosureAsLastMethodParameter, UnnecessaryGetter */
package com.lesfurets.jenkins.unit.declarative

/* groovylint-disable-next-line NoWildcardImports */
import static org.assertj.core.api.Assertions.*

import static com.lesfurets.jenkins.unit.global.lib.LibraryConfiguration.library
import static com.lesfurets.jenkins.unit.global.lib.ProjectSource.projectSource
import com.lesfurets.jenkins.unit.LibClassLoader

import org.junit.Before
import org.junit.Test

class HelloPipelineSpec extends DeclarativePipelineTest {

    @Before
    @Override
    void setUp() {
        scriptRoots = ['test/vars']
        scriptExtension = 'groovy'
        super.setUp()
        // Mock the 'script' step used in declarative pipeline steps block
        helper.registerAllowedMethod('script', [Closure], { Closure c ->
            c.delegate = delegate
            helper.callClosure(c)
        })
    }

    @Test void deployTypeInfoPipeline() {
        // Load our local shared libraries
        // @see https://github.com/jenkinsci/JenkinsPipelineUnit/blob/master/README.md#library-source-retrievers
        /* groovylint-disable-next-line NoDef, VariableTypeRequired */
        def library = library().name('Jankins_Shared_Libraries')
                        .defaultVersion('<notNeeded>')
                        .allowOverride(true)
                        .implicit(true)
                        .targetPath('<notNeeded>')
                        .retriever(projectSource())
                        .build()
        helper.registerSharedLibrary(library)

        // Registration fo pipeline method 'library'
        // should be after you register the shared library
        // so unfortunately you cannot move it to the super class
        // @see https://github.com/jenkinsci/JenkinsPipelineUnit/blob/master/README.md#loading-library-dynamically
        helper.registerAllowedMethod('library', [String], { String expression ->
            helper.getLibLoader().loadLibrary(expression)
            println helper.getLibLoader().libRecords
            return new LibClassLoader(helper, null)
        })

        runScript('helloPipeline.groovy')
        printCallStack()

        // Check that we got expected output
        assertCallStackContains('hello')

        assertJobStatusSuccess()
    }

}
