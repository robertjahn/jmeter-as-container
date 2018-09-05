pipeline {
    parameters {
        string(name: 'SCRIPT_NAME', defaultValue: 'basiccheck.jmx', description: 'The script you want to execute', trim: true)
        string(name: 'SERVER_URL',  defaultValue: 'user.jx-staging.35.233.18.9.nip.io', description: 'Please enter the URI or the IP of your service you want to run your test against', trim: true)
        string(name: 'SERVER_PORT', defaultValue: '80', description: 'Please enter the port of the endpoint', trim: true)
        string(name: 'VUCount',     defaultValue: '1', description: 'Number of Virtual Users to be executed. ', trim: true)
        string(name: 'LoopCount',   defaultValue: '1', description: 'Number of iterations every virtual user executes', trim: true)
        string(name: 'DT_LTN',      defaultValue: 'DTLoadTest', description: 'For scripts that have been setup to pass x-dynatrace-test this will pass the LTN Request Attribute', trim: true)
        string(name: 'CHECK_PATH',  defaultValue: '/health', description: 'This parameter is only good for scripts that use this parameter, e.g: basiccheck.jmx', trim: true)
    }

    agent {
        label "jenkins-go"
    }
    environment {
        ORG               = 'acm-workshop'
        APP_NAME          = 'jmeter'
        GIT_PROVIDER      = 'github.com'
        
        RESULTDIR         = 'results'
    }    

    stages {
        stage('RunTest') {
            steps
            {
                container('go') {
                    sh 'docker rm load-test || true'
                    
                    sh "rm -f -r $RESULTDIR"
                    sh "mkdir $RESULTDIR"
                    sh "echo 'launching container'"
                    
                    sh "docker run --name jmeter-test -v /home/jenkins/workspace/$ORG/run_load_test/$RESULTDIR:/results --rm $DOCKER_REGISTRY/$ORG/$APP_NAME ./jmeter/bin/jmeter.sh -n -t /scripts/$SCRIPT_NAME -e -l result.tlf -JSERVER_URL='$SERVER_URL' -JDT_LTN='$DT_LTN' -JVUCount='$VUCount' -JLoopCount='$LoopCount' -JCHECK_PATH='$CHECK_PATH' -JSERVER_PORT='$SERVER_PORT'"
                    // sh "docker run --name jmeter-test -v /home/jenkins/workspace/$ORG/run_load_test/$RESULTDIR:/results --rm $DOCKER_REGISTRY/$ORG/$APP_NAME ./jmeter/bin/jmeter.sh -n -t /scripts/$SCRIPT_NAME -e -o /results -l result.tlf -JSERVER_URL='$SERVER_URL' -JDT_LTN='$DT_LTN' -JVUCount='$VUCount' -JLoopCount='$LoopCount' -JCHECK_PATH='$CHECK_PATH'"
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                container('go') {
                    // clean up after load test
                    sh 'docker rm load-test || true'
                }
            }
        }
    }
}