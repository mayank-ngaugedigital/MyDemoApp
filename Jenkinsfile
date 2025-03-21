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
    def changedFiles = []

    stage('Checkout Source from Git') {
        checkout([
            $class: 'GitSCM',
            branches: [[name: GIT_BRANCH]],
            userRemoteConfigs: [[url: GIT_REPO_URL]]
        ])
    }

    stage('Detect Changed Files') {
        script {
            try {
                def lastCommit = bat(script: 'git rev-parse HEAD~1', returnStdout: true).trim()
                changedFiles = bat(script: "git diff --name-only ${lastCommit}", returnStdout: true).trim().split("\n")

                if (changedFiles.length == 0 || changedFiles[0] == '') {
                    echo "No changed files detected. Skipping deployment."
                    currentBuild.result = 'SUCCESS'
                    return
                } else {
                    echo "Changed files: ${changedFiles.join(', ')}"
                }
            } catch (Exception e) {
                error "Error detecting changed files: ${e.message}"
            }
        }
    }

    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
        stage('Deploy Changed Files') {
            script {
                try {
                    def deployCommand = "\"${toolbelt}\" project deploy start --source-dir ${changedFiles.join(' ')} --target-org ${HUB_ORG}"
                    def rc

                    if (isUnix()) {
                        rc = sh returnStatus: true, script: deployCommand
                    } else {
                        rc = bat returnStatus: true, script: deployCommand
                    }

                    if (rc != 0) {
                        error 'Deployment failed'
                    } else {
                        echo "Deployment successful"
                    }
                } catch (Exception e) {
                    error "Error during deployment: ${e.message}"
                }
            }
        }
    }
}
