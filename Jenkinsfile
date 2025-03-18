import groovy.json.JsonSlurperClassic

node {
    def BUILD_NUMBER = env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR = "tests/${BUILD_NUMBER}"
    def SFDC_USERNAME

    def HUB_ORG = env.HUB_ORG_DH
    def SFDC_HOST = env.SFDC_HOST_DH
    def JWT_KEY_CRED_ID = env.JWT_CRED_ID_DH
    def CONNECTED_APP_CONSUMER_KEY = env.CONNECTED_APP_CONSUMER_KEY_DH

    def QA_HUB_ORG = "test-jpzd4qsbxycg@example.com"
    def QA_SFDC_HOST = "https://login.salesforce.com/"
    def QA_JWT_KEY_CRED_ID = "b57e8c8c-1d7b-4968-86ef-a1b86e39504f"
    def QA_CONNECTED_APP_CONSUMER_KEY = "3MVG9W_ynb0f8co7mSJIX.c3zAZeQCvHkCwRZnmYUQ0FBm1NHRC8AhweqWnSgvGA_A9qL6sZKWc1FVZJ2OW9y"

    def toolbelt = "C:/Program Files/sf/bin/sfdx.cmd"

    stage('Checkout Source') {
        checkout scm
    }

    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
        stage('Deploy to Dev Hub') {
            def rc
            if (isUnix()) {
                rc = sh returnStatus: true, script: "\"${toolbelt}\" org login jwt --client-id ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwt-key-file ${jwt_key_file} --set-default-dev-hub --instance-url ${SFDC_HOST}"
            } else {
                rc = bat returnStatus: true, script: "\"${toolbelt}\" org login jwt --client-id ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwt-key-file \"${jwt_key_file}\" --set-default-dev-hub --instance-url ${SFDC_HOST}"
            }

            if (rc != 0) { 
                error 'Hub org authorization failed' 
            }

            println "Authorization successful, proceeding with deployment."

            def rmsg
            if (isUnix()) {
                rmsg = sh returnStdout: true, script: "\"${toolbelt}\" project deploy start --manifest manifest/package.xml --target-org ${HUB_ORG}"
            } else {
                rmsg = bat returnStdout: true, script: "\"${toolbelt}\" project deploy start --manifest manifest/package.xml --target-org ${HUB_ORG}"
            }

            println "Deployment Output:\n${rmsg}"
        }
    }

    // Deploying to QA Org after successful deployment to Dev Hub
    withCredentials([file(credentialsId: QA_JWT_KEY_CRED_ID, variable: 'qa_jwt_key_file')]) {
        stage('Deploy to QA Org') {
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
