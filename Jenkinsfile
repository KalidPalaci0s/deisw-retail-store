pipeline {
    agent any

    environment {
        PATH = "/Applications/Docker.app/Contents/Resources/bin:/opt/homebrew/bin:/usr/local/bin:${env.PATH}"
    }

    stages {
        stage('Verificar Docker') {
            steps {
                sh 'docker version'
            }
        }

        stage('Verificar Java 26') {
            steps {
                sh '''
                    docker run --rm \
                      maven:3.9-eclipse-temurin-26 \
                      java -version
                '''
            }
        }

        stage('Checkout GitHub') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/KalidPalaci0s/deisw-retail-store.git'
            }
        }

        stage('Maven Tests') {
            steps {
                sh '''
                    docker run --rm \
                      -v "$PWD":/workspace \
                      -v pc2-maven-cache:/root/.m2 \
                      -w /workspace \
                      maven:3.9-eclipse-temurin-26 \
                      mvn -B -ntp test
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-PC2') {
                    sh '''
                        set +x

                        docker run --rm \
                          -e SONAR_TOKEN="$SONAR_AUTH_TOKEN" \
                          -v "$PWD":/workspace \
                          -v pc2-maven-cache:/root/.m2 \
                          -w /workspace \
                          maven:3.9-eclipse-temurin-26 \
                          mvn -B -ntp \
                          org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                          -Dsonar.projectKey=pc2-u201913639 \
                          -Dsonar.host.url=http://host.docker.internal:9000
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t kalidpalacios/retail-store-u201913639:latest .'
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-pc2',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_TOKEN'
                )]) {
                    sh '''
                        set +x
                        export DOCKER_CONFIG="$(mktemp -d)"
                        trap 'rm -rf "$DOCKER_CONFIG"' EXIT

                        printf '%s' "$DOCKER_TOKEN" |
                          docker login --username "$DOCKER_USER" --password-stdin

                        docker push kalidpalacios/retail-store-u201913639:latest
                    '''
                }
            }
        }

    }
}
