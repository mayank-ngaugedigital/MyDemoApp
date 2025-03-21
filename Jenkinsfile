import groovy.json.JsonSlurperClassic

node {
    def BUILD_NUMBER = env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR = "tests/${BUILD_NUMBER}"
    def SFDC_USERNAME

    def HUB_ORG = env.HUB_ORG_DH
    def GIT_REPO_URL = "https://github.com/mayank-ngaugedigital/MyDemoApp"
    def GIT_BRANCH = "main"
    def SFDC_HOST = env.SFDC_HOST_DH
    def JWT_KEY_CRED_ID = env.JWT_CRED_ID_DH
    def CONNECTED_APP_CONSUMER_KEY = env.CONNECTED_APP_CONSUMER_KEY_DH

    def QA_HUB_ORG = "mayank.joshi122@agentforce.com"
    def QA_SFDC_HOST = "https://login.salesforce.com/"
    def QA_JWT_KEY_CRED_ID = "b57e8c8c-1d7b-4968-86ef-a1b86e39504f"
    def QA_CONNECTED_APP_CONSUMER_KEY = "3MVG9dAEux2v1sLue1HMQKDk3cI6_j04l_8qbHtsM8yE7HFkAVvKXlHIB2yEoavswobilwgHmAPznoz_cREvZ"

    def toolbelt = "C:/Program Files/sf/bin/sfdx.cmd"

    stage('Checkout Source from Git') {
        checkout([
            $class: 'GitSCM',
            branches: [[name: GIT_BRANCH]],
            userRemoteConfigs: [[url: GIT_REPO_URL]]
        ])
    }

    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
        stage('Check for Conflicts and Retrieve Remote Changes') {
            def rc
            if (isUnix()) {
                rc = sh returnStatus: true, script: "\"${toolbelt}\" project deploy start --manifest manifest/package.xml --target-org ${HUB_ORG} --dry-run"
            } else {
                rc = bat returnStatus: true, script: "\"${toolbelt}\" project deploy start --manifest manifest/package.xml --target-org ${HUB_ORG} --dry-run"
            }

            if (rc != 0) {
                println 'Conflicts detected! Retrieving remote changes for manual merge...'
                
                if (isUnix()) {
                    sh "\"${toolbelt}\" project retrieve start --manifest manifest/package.xml --target-org ${HUB_ORG}"
                } else {
                    bat "\"${toolbelt}\" project retrieve start --manifest manifest/package.xml --target-org ${HUB_ORG}"
                }
                
                println 'Please resolve conflicts manually before proceeding.'
                error "Merge conflicts found. Resolve them manually and restart the build."
            } else {
                println 'No conflicts detected.'
            }
        }
    }

    withCredentials([file(credentialsId: QA_JWT_KEY_CRED_ID, variable: 'qa_jwt_key_file')]) {
        stage('Deploy to QA Org After Merging') {
            def rc
            if (isUnix()) {
                rc = sh returnStatus: true, script: "\"${toolbelt}\" org login jwt --client-id ${QA_CONNECTED_APP_CONSUMER_KEY} --username ${QA_HUB_ORG} --jwt-key-file ${qa_jwt_key_file} --instance-url ${QA_SFDC_HOST}"
            } else {
                rc = bat returnStatus: true, script: "\"${toolbelt}\" org login jwt --client-id ${QA_CONNECTED_APP_CONSUMER_KEY} --username ${QA_HUB_ORG} --jwt-key-file \"${qa_jwt_key_file}\" --instance-url ${QA_SFDC_HOST}"
            }

            if (rc != 0) { 
                error 'QA org authorization failed' 
            }

            println "QA Org Authorization successful, proceeding with QA deployment."

            def rmsg
            if (isUnix()) {
                rmsg = sh returnStdout: true, script: "\"${toolbelt}\" project deploy start --manifest manifest/package.xml --target-org ${QA_HUB_ORG}"
            } else {
                rmsg = bat returnStdout: true, script: "\"${toolbelt}\" project deploy start --manifest manifest/package.xml --target-org ${QA_HUB_ORG}"
            }

            println "QA Deployment Output:\n${rmsg}"
        }
    }
}
