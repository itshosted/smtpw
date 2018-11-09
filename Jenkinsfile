pipeline {
  agent {
    node {
      label 'centos6_golang'
    }
  }

  stages {
    stage('Update golang to latest version') {
			steps {
				sh 'yum update -y golang'
			}
    } // stage update golang

    stage('build smtpw'){
      steps {
        sh '''
          go version
          export GOPATH=/home/jenkins/workspace
          mkdir -p \$GOPATH/src/github.com/itshosted \$GOPATH/bin/
          REPONAME=`echo ${WORKSPACE} | cut -d '_' -f 2`
          ln -s ${WORKSPACE} \$GOPATH/src/\${REPONAME}

          # Build smtpw
          cd \$GOPATH/src/\${REPONAME}
          go get
          go build -ldflags "-X main.version=${BRANCH_NAME}-${GIT_COMMIT:0:6}-${BUILD_NUMBER}"

          mkdir -p ${WORKSPACE}/build
		      mv \$GOPATH/bin/* ${WORKSPACE}/build
          cp ${WORKSPACE}/smtpw.sh ${WORKSPACE}/build
          cp ${WORKSPACE}/smtpw.target ${WORKSPACE}/build
          cp ${WORKSPACE}/smtp*.service ${WORKSPACE}/build
        '''
      }
    } // stage build

    stage('Store smtpw artifact') {
			steps {
				archiveArtifacts artifacts: 'build/*'
			}
    } // stage store

  } // steps

} // pipeline
