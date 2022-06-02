pipeline {
    agent {
        label 'node'
    }
    stages {
        stage('A') {
            steps {
                script {
                    echo 'hello!'
                }
            }
        }
    }
}
