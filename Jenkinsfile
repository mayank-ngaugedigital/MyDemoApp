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

    def QA_HUB_ORG = "test-jpzd4qsbxycg@example.com"
    def QA_SFDC_HOST = "https://login.salesforce.com/"
    def QA_JWT_KEY_CRED_ID = "b57e8c8c-1d7b-4968-86ef-a1b86e39504f"
    def QA_CONNECTED_APP_CONSUMER_KEY = "3MVG9W_ynb0f8co7mSJIX.c3zAZeQCvHkCwRZnmYUQ0FBm1NHRC8AhweqWnSgvGA_A9qL6sZKWc1FVZJ2OW9y"

    def toolbelt = "C:/Program Files/sf/bin/sfdx.cmd"
    stage('Checkout Source from Git') {
        checkout([
            $class: 'GitSCM',
            branches: [[name: GIT_BRANCH]],
            userRemoteConfigs: [[url: GIT_REPO_URL]]
        ])
    }

    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
        stage('Check for Conflicts') {
            def rc
            if (isUnix()) {
                rc = sh returnStatus: true, script: "\"${toolbelt}\" project deploy start --manifest manifest/package.xml --target-org ${HUB_ORG} --dry-run"
            } else {
                rc = bat returnStatus: true, script: "\"${toolbelt}\" project deploy start --manifest manifest/package.xml --target-org ${HUB_ORG} --dry-run"
            }

            if (rc != 0) { 
                error 'Conflicts detected in Git changes! Resolve them before deployment.' 
            }
            println "No conflicts detected. Proceeding with deployment."
        }

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
