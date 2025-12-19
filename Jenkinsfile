pipeline {
    agent { label 'worker' }

    stages {
        stage("Build and Push") {
            steps {
                sh 'cd vote'
                sh 'docker build -t rupeshkumar2025/vote:V3 .'
            }
        }

        stage("Deploy") {
            steps {
                sh 'echo docker run'
            }
        }
    }
}
