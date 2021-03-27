pipeline {

  agent { node { label 'master_node'} }

  environment {
    GOPATH="${WORKSPACE}/"
    GOBIN="${WORKSPACE}/bin"
    BINARY_NAME="smtpw"
  }

  stages {

    stage("Preparation") {
      steps {
        cleanWs()
        sh "mkdir -p ${WORKSPACE}/{bin,pkg,src}"
        sh "docker pull golang:1-alpine"
        dir ("${WORKSPACE}/src/${BINARY_NAME}") {
          checkout scm
          sh "go get -t ."
        }
      }
    }

    stage("Static Analysis"){
      parallel {
        // TODO: Html and HtmlEmbed should be HTML and HTMLEmbed but this is a breaking change
        // TODO: so for now we disable golint
        // stage('golint'){
        //   steps {
        //     dir ("${WORKSPACE}/src/smtpw") {
        //       sh "go get -u golang.org/x/lint/golint"
        //       sh "${WORKSPACE}/bin/golint -set_exit_status ./..."
        //     }
        //   }
        // }

        stage('go vet'){
          steps {
            dir ("${WORKSPACE}/src/${BINARY_NAME}") {
              sh "go vet ./..."
            }
          }
        }

        stage('go test'){
          steps {
            dir ("${WORKSPACE}/src/${BINARY_NAME}") {
              sh "go test ./..."
            }
          }
        }

      } // parallel
    }

    stage("go build"){
      steps {
        dir ("${WORKSPACE}/src/${BINARY_NAME}") {
          sh '''
            CGO_ENABLED=0 GOOS=linux go build -mod=mod -a -installsuffix cgo -ldflags="-X main.version=$(git describe --always --long --dirty --all)-$(date +%Y-%m-%d-%H:%M)";
          '''
        }
      }
    }

    stage("Docker Build") {
      parallel {

        stage("Production") {
          when {
            branch 'master'
          }
          steps {
            dir ("${WORKSPACE}/src/${BINARY_NAME}") {
              // Build image
              sh "docker build -f Dockerfile -t usenetfarm/${BINARY_NAME} ."
              sh "docker tag usenetfarm/${BINARY_NAME} usenetfarm/${BINARY_NAME}:${env.BUILD_NUMBER}"
            }
          }
        }
        stage("Non-Production") {
          when {
            not {
              branch 'master'
            }
          }
          steps {
            dir ("${WORKSPACE}/src/${BINARY_NAME}") {
              // Build image
              sh "docker build -f Dockerfile -t usenetfarm/${BINARY_NAME}:${BRANCH_NAME}${BUILD_NUMBER} ."
              // sh "docker tag usenetfarm/${BINARY_NAME} usenetfarm/${BINARY_NAME}:${BRANCH_NAME}${BUILD_NUMBER}"
            }
          }
        }

      }
    }

    stage("Docker push") {
      when {
        branch 'master'
      }
      steps {
        withDockerRegistry([ credentialsId: "dockerhub", url: "" ]) {
          sh "docker push usenetfarm/${BINARY_NAME}"
        }
      }
    }

    stage("Archive smtpw") {
      steps {
        archiveArtifacts artifacts: "bin/${BINARY_NAME}"
        sh "ssh repos.it.lan 'mkdir -p /var/www/repos/${BINARY_NAME}/${BRANCH_NAME}/'"

        sh "scp bin/${BINARY_NAME} repos.it.lan:/var/www/repos/${BINARY_NAME}/${BRANCH_NAME}/${BINARY_NAME}.${BUILD_NUMBER}"
        sh "ssh repos.it.lan 'ln -sfn /var/www/repos/${BINARY_NAME}/${BRANCH_NAME}/${BINARY_NAME}.${BUILD_NUMBER} /var/www/repos/${BINARY_NAME}/${BRANCH_NAME}/${BINARY_NAME}.latest'"

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
