pipeline {
    agent { label 'ca-brightside-agent' }
    stages {
        stage('build') {
            environment {
                CREATE_PROFILE = "./jenkins/profileCreation.sh"
                BUILD_COBOL = "./jenkins/build.sh"
            }
            steps {
                sh 'npm --version'
                sh 'bright --version'
                sh 'npm install'
                withCredentials([usernamePassword(credentialsId: 'brightProfCreds20', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD'), string(credentialsId: 'host', variable: 'HOST'), string(credentialsId: 'port', variable: 'PORT')]) {
                    sh "chmod +x $CREATE_PROFILE && dbus-launch $CREATE_PROFILE"
                }
                sh "chmod +x $BUILD_COBOL && dbus-launch $BUILD_COBOL"
            }
        }
        stage('deploy') {
            environment {
                DEPLOY_SCRIPT = "./jenkins/deploy.sh"
            }
            steps {
                sh "chmod +x $DEPLOY_SCRIPT && dbus-launch $DEPLOY_SCRIPT"
            }
        }
        stage('test') {
            environment {
                TEST_SCRIPT = "./jenkins/test.sh"
            }
            steps {
                sh "chmod +x $TEST_SCRIPT && dbus-launch $TEST_SCRIPT"
            }
        }
    }
}