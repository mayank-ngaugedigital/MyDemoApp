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

        stage('Check for Changes Before Deployment') {
            script {
                def changes = bat(script: "git diff --name-only HEAD~1", returnStdout: true).trim()
                if (!changes) {
                    error "No changes detected. Skipping deployment."
                }
            }
        }

        stage('Generate package.xml') {
            script {
                bat 'generate-package.bat'
            }
        }

        stage('Preview Deployment') {
            script {
                def previewOutput = bat(returnStdout: true, script: "\"${toolbelt}\" project deploy preview --manifest package.xml --target-org ${HUB_ORG}")
                println "Deployment Preview Output: ${previewOutput}"

                if (previewOutput.contains("No local changes to deploy")) {
                    error "Nothing to deploy. Skipping deployment."
                }
            }
        }

        withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
            stage('Deploy to Dev Hub') {
                def rc = bat returnStatus: true, script: "\"${toolbelt}\" org login jwt --client-id ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwt-key-file \"${jwt_key_file}\" --instance-url ${SFDC_HOST}"
                if (rc != 0) { 
                    error 'Hub org authorization failed' 
                }

                def deployOutput = bat returnStdout: true, script: "\"${toolbelt}\" project deploy start --manifest package.xml --target-org ${HUB_ORG} --ignore-conflicts"
                println "Dev Hub Deployment Output: ${deployOutput}"

                if (deployOutput.contains("Error")) {
                    error 'Deployment to Dev Hub failed.'
                }
                println "✅ Dev Hub Deployment Successful."
            }
        }

        withCredentials([file(credentialsId: QA_JWT_KEY_CRED_ID, variable: 'qa_jwt_key_file')]) {
            stage('Deploy to QA Org') {
                def rc = bat returnStatus: true, script: "\"${toolbelt}\" org login jwt --client-id ${QA_CONNECTED_APP_CONSUMER_KEY} --username ${QA_HUB_ORG} --jwt-key-file \"${qa_jwt_key_file}\" --instance-url ${QA_SFDC_HOST}"
                if (rc != 0) { 
                    error 'QA org authorization failed' 
                }

                def deployOutput = bat returnStdout: true, script: "\"${toolbelt}\" project deploy start --manifest package.xml --target-org ${QA_HUB_ORG} --ignore-conflicts"
                println "QA Deployment Output: ${deployOutput}"

                if (deployOutput.contains("Error")) {
                    error 'Deployment to QA failed.'
                }
                println "✅ QA Deployment Successful."
            }
        }

        stage('Generate New package.xml for Next Changes') {
            script {
                bat 'generate-package.bat' 
            }
        }

    } catch (Exception e) {
        println "❌ Deployment Failed: ${e.message}"
        stage('Rollback Deployment') {
            bat "\"${toolbelt}\" project deploy start --manifest package.xml --target-org ${HUB_ORG}"
            bat "\"${toolbelt}\" project deploy start --manifest package.xml --target-org ${QA_HUB_ORG}"
            error "Rollback triggered. Please check logs."
        }
    }
}
