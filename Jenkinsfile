pipeline {
    agent { label 'worker' }

    triggers {
        githubPush()
    }

    options {
        timeout(time: 5, unit: 'MINUTES')
        retry(3)
        timestamps()
    }

    environment {
        DOCKER_REGISTRY = 'rupeshkumar2025'
        APP_NAME        = 'vote'
    }

    stages {
        stage("Checkout") {
            steps {
                checkout scm   // Automatically checks out the branch that triggered the webhook
            }
        }

        stage("Build and Push") {
            steps {
                script {
                    // Map branch -> environment
                    def envMap = [
                        "main": "PROD",
                        "develop": "DEV",
                        "qa": "QA",
                        "uat": "UAT"
                    ]

                    def branchName = env.GIT_BRANCH.replaceFirst(/^origin\//, "")
                    def targetEnv = envMap.get(branchName, "UNKNOWN")

                    if (targetEnv == "UNKNOWN") {
                        error "Branch ${branchName} not mapped to an environment!"
                    }

                    sh """
                    echo "Building Docker image for ${targetEnv} environment from branch ${branchName}..."
                    cd ${APP_NAME}
                    docker build -t ${DOCKER_REGISTRY}/${APP_NAME}:${targetEnv}-${branchName} .
                    docker push ${DOCKER_REGISTRY}/${APP_NAME}:${targetEnv}-${branchName}
                    """
                }
            }
        }

        stage("Deploy") {
            steps {
                script {
                    def branchName = env.GIT_BRANCH.replaceFirst(/^origin\//, "")
                    def envMap = [
                        "main": "PROD",
                        "develop": "DEV",
                        "qa": "QA",
                        "uat": "UAT"
                    ]
                    def targetEnv = envMap.get(branchName, "UNKNOWN")

                    if (targetEnv != "UNKNOWN") {
                        sh """
                        echo "Deploying to ${targetEnv}..."
                        docker run -d --name ${APP_NAME}-${targetEnv.toLowerCase()} ${DOCKER_REGISTRY}/${APP_NAME}:${targetEnv}-${branchName}
                        """
                    }
                }
            }
        }
    }
}
