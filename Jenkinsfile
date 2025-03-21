import groovy.json.JsonSlurperClassic

node {
    def BUILD_NUMBER = env.BUILD_NUMBER
    def GIT_REPO_URL = "https://github.com/mayank-ngaugedigital/MyDemoApp"
    def GIT_BRANCH = "main"

    def HUB_ORG = env.HUB_ORG_DH
    def SFDC_HOST = env.SFDC_HOST_DH
    def JWT_KEY_CRED_ID = env.JWT_CRED_ID_DH
    def CONNECTED_APP_CONSUMER_KEY = env.CONNECTED_APP_CONSUMER_KEY_DH

    def QA_HUB_ORG = "mayank.joshi122@agentforce.com"
    def QA_SFDC_HOST = "https://login.salesforce.com/"
    def QA_JWT_KEY_CRED_ID = "b57e8c8c-1d7b-4968-86ef-a1b86e39504f"
    def QA_CONNECTED_APP_CONSUMER_KEY = "3MVG9dAEux2v1sLue1HMQKDk3cI6_j04l_8qbHtsM8yE7HFkAVvKXlHIB2yEoavswobilwgHmAPznoz_cREvZ"

    def toolbelt = "C:/Program Files/sf/bin/sfdx.cmd"

    try {
        stage('Checkout Source from Git') {
            checkout([
                $class: 'GitSCM',
                branches: [[name: GIT_BRANCH]],
                userRemoteConfigs: [[url: GIT_REPO_URL]]
            ])
        }

        stage('Generate package.xml (Only Modified Files)') {
            script {
                bat 'generate-package.bat'
            }
        }

        withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
            stage('Deploy to Dev Hub (Ignoring Conflicts)') {
                def rc = bat returnStatus: true, script: "\"${toolbelt}\" org login jwt --client-id ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwt-key-file \"${jwt_key_file}\" --instance-url ${SFDC_HOST}"
                if (rc != 0) { 
                    error 'Hub org authorization failed' 
                }

                def deployOutput = bat returnStatus: true, script: "\"${toolbelt}\" project deploy start --manifest package.xml --target-org ${HUB_ORG} --ignore-conflicts"
                if (deployOutput != 0) {
                    error 'Deployment to Dev Hub failed, triggering rollback...'
                }
                println "Dev Hub Deployment Successful."
            }
        }

        withCredentials([file(credentialsId: QA_JWT_KEY_CRED_ID, variable: 'qa_jwt_key_file')]) {
            stage('Deploy to QA Org (After Successful Dev Deployment)') {
                def rc = bat returnStatus: true, script: "\"${toolbelt}\" org login jwt --client-id ${QA_CONNECTED_APP_CONSUMER_KEY} --username ${QA_HUB_ORG} --jwt-key-file \"${qa_jwt_key_file}\" --instance-url ${QA_SFDC_HOST}"
                if (rc != 0) { 
                    error 'QA org authorization failed' 
                }

                def deployOutput = bat returnStatus: true, script: "\"${toolbelt}\" project deploy start --manifest package.xml --target-org ${QA_HUB_ORG} --ignore-conflicts"
                if (deployOutput != 0) {
                    error 'Deployment to QA failed, triggering rollback...'
                }
                println "QA Deployment Successful."
            }
        }

        stage('Generate New package.xml for Next Changes') {
            script {
                bat 'generate-package.bat' 
            }
        }

    } catch (Exception e) {
        println "Deployment Failed: ${e.message}"
        stage('Rollback to Last Successful Deployment') {
            bat "\"${toolbelt}\" project deploy start --manifest package.xml --target-org ${HUB_ORG} --rollback-on-error"
            bat "\"${toolbelt}\" project deploy start --manifest package.xml --target-org ${QA_HUB_ORG} --rollback-on-error"
            error "Deployment failed and rollback triggered. Please check logs."
        }
    }
}
