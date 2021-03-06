pipeline {
    parameters {
        choice(name: 'BUILD_JMETER', choices: 'yes\nno', description: 'Do you want to rebuild the JMeter Container. DO IT if scripts have changed!')
        string(name: 'SCRIPT_NAME', defaultValue: 'basiccheck.jmx', description: 'The script you want to execute', trim: true)
        string(name: 'SERVER_URL', defaultValue: '104.196.41.214', description: 'Please enter the URI or the IP of your service you want to run your test against', trim: true)
        string(name: 'SERVER_PORT', defaultValue: '80', description: 'Please enter the port of the endpoint', trim: true)
        string(name: 'CHECK_PATH', defaultValue: '/health', description: 'This parameter is only good for scripts that use this parameter, e.g: basiccheck.jmx', trim: true)
        string(name: 'VU_COUNT', defaultValue: '1', description: 'Number of Virtual Users to be executed. ', trim: true)
        string(name: 'LOOP_COUNT', defaultValue: '1', description: 'Number of iterations every virtual user executes', trim: true)
        string(name: 'THINK_TIME', defaultValue: '250', description: 'Default Thinktime between load testing steps')
        string(name: 'DT_LTN', defaultValue: 'DTLoadTest', description: 'For scripts that have been setup to pass x-dynatrace-test this will pass the LTN Request Attribute', trim: true)
        choice(name: 'FUNC_VALIDATION', choices: 'yes\nno', description: 'BREAK the Pipeline if there is a functional issue?')
        string(name: 'AVG_RT_VALIDATION', defaultValue: '0', description: 'BREAK the Pipeline if the average response time exceeds the passed value. 0 means NO VALIDATION')
    }
    agent any
    environment {
        DOCKER_REGISTRY = 'robjahn'
        ORG = 'acm-workshop'
        APP_NAME = 'jmeter-as-container'
        GIT_PROVIDER = 'github.com'

        RESULTDIR = 'results'
    }

    stages {
        stage('Build') {
            when {
                // Only run if this pipeline exeuction is supposed to just build the container!
                expression { params.BUILD_JMETER == 'yes' }
            }
            steps
                    {
                        script {
                            checkout scm
                            def app
                            app = docker.build("$DOCKER_REGISTRY/$APP_NAME")
                            docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
                                app.push("latest")
                            }
                        }
                    }
        }

        stage('TestPrep') {
            when {
                // Only run if this is not just for building jmeter
                expression { params.BUILD_JMETER == 'no' }
            }
            steps {
                // stop and remove Jmeter docker container if still there
                sh "./cleanup_docker.sh $DOCKER_REGISTRY/$APP_NAME"
                
                // lets create the results directory
                sh "rm -f -r $RESULTDIR"
                sh "mkdir $RESULTDIR"
            }
        }

        stage('RunTest') {
            when {
                // Only run if this is not just for building jmeter
                expression { params.BUILD_JMETER == 'no' }
            }
            steps
                    {
            
                        echo "launching container and put result in output.txt"
                        sh "echo Running with VU_COUNT=$VU_COUNT and LOOP_COUNT=$LOOP_COUNT" 

                        sh "docker run -v /var/lib/jenkins/workspace/$ORG/$APP_NAME/$RESULTDIR:/results --rm $DOCKER_REGISTRY/$APP_NAME ./jmeter/bin/jmeter.sh -n -t /scripts/$SCRIPT_NAME -e -l results/result.tlf -JSERVER_URL='$SERVER_URL' -JDT_LTN='$DT_LTN' -JVUCount='$VU_COUNT' -JLoopCount='$LOOP_COUNT' -JCHECK_PATH='$CHECK_PATH' -JSERVER_PORT='$SERVER_PORT' -JThinkTime='$THINK_TIME' > output.txt"
            
                        // Lets do the functional validation if FUNC_VALIDATION=='yes'
                        sh '''
                            ERROR_COUNT=$(awk '/summary =/ {print $15;}' output.txt)
                            if [ "$FUNC_VALIDATION" = "yes" ] && [ $ERROR_COUNT -gt 0 ]
                            then
                                echo "More than 1 error"
                            exit 1
                            fi
                        '''

                        // Lets do the performance validation if AVG_RT_VALIDATION > 0
                        sh '''
                             AVG_RT=$(awk '/summary =/ {print $9;}' output.txt)
                             echo "AVG_RT = $AVG_RT"
                             if [ $AVG_RT_VALIDATION -gt 0 ] && [ $AVG_RT_VALIDATION -gt $AVG_RT ]
                             then
                             echo "Response Time Threshold Violation: $AVG_RT > $$AVG_RT_VALIDATION"
                             exit 1
                             fi
                        '''
                    }
            post {
                always {
                    archiveArtifacts artifacts: 'results/**', fingerprint: true, allowEmptyArchive: true
                    archiveArtifacts artifacts: 'output.txt', fingerprint: true, allowEmptyArchive: true
                }
            }
        }
    }
}
