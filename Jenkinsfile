pipeline{
    agent {lable 'worker'}
    stages{
        stage("Build and Push"){
            steps{
                sh "echo vote"
                sh "docker build -t rupeshkumar2025/Vote:V3"
            }
        }
        stage("Deploy"){
            Steps{
                sh "echo docker run"
            }
        }
    }
    
}