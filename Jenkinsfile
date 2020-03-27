pipeline {

  agent { node { label 'master_node'} }

  environment {
    GOPATH="${WORKSPACE}"
    GOBIN="${WORKSPACE}/bin"
  }

  stages {
    stage("Preparation") {
      steps {
        sh "mkdir -p ${WORKSPACE}/{bin,pkg,src}"
        dir ("${WORKSPACE}/src/smtpw") {
          checkout scm
          sh "go get"
        }
      }
    }

    stage("Static Analysis"){
      parallel {

        stage('golint'){
          steps {
            dir ("${WORKSPACE}/src/smtpw") {
              sh "go get -u golang.org/x/lint/golint"
              sh "${WORKSPACE}/bin/golint -set_exit_status ./..."
            }
          }
        }

        stage('go vet'){
          steps {
            dir ("${WORKSPACE}/src/smtpw") {
              sh "go vet ./..."
            }
          }
        }

        stage('go test'){
          steps {
            dir ("${WORKSPACE}/src/smtpw") {
              sh "go test ./..."
            }
          }
        }

      } // parallel
    } // stage Static Analysus

    stage("go build"){
      steps {
        dir ("${WORKSPACE}/src/smtpw") {
          sh '''
            GOOS=linux GOARCH=amd64 go build -i -v -ldflags="-X main.version=$(git describe --always --long --dirty --all)";
          '''
        }
      }
    }
    stage("Archive smtpw") {
      steps {
        archiveArtifacts artifacts: "bin/smtpw"
        sh "ssh repos.it.lan 'mkdir -p /var/www/repos/smtpw/${BRANCH_NAME}/'"

        sh "scp bin/smtpw repos.it.lan:/var/www/repos/smtpw/${BRANCH_NAME}/smtpw.${BUILD_NUMBER}"
        sh "ssh repos.it.lan 'ln -sfn /var/www/repos/smtpw/${BRANCH_NAME}/smtpw.${BUILD_NUMBER} /var/www/repos/smtpw/${BRANCH_NAME}/smtpw.latest'"

      }
    }
  } // stages
  post {
    success {
      slackSend (message: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})", color: '#00ff04')
    }
    failure {
      slackSend (message: "FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})", color: '#FF0000')
    }
  }
} // pipeline
