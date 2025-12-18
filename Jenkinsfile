pipeline{
    agent {lable 'worker'}
    stages{
        stage("Build and Push"){
            steps{
                sh "echo vote"
                sh "echo docker build -t rupeshkumar2025/Vote:V3"
            }
        }
        stage("Deploy"){
            steps{
                sh "echo docker run"
            }
        }
    }
    
}