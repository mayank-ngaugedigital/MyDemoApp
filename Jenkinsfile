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

    stage('Generate package.xml for changed files') {
        sh 'git fetch origin'  // Ensure latest changes are fetched
        def changedFiles = sh(script: "git diff --name-only origin/main HEAD", returnStdout: true).trim().split("\n")
        
        def metadataMap = [
            "classes": "ApexClass",
            "triggers": "ApexTrigger",
            "lwc": "LightningComponentBundle"
        ]

        def packageXml = """<?xml version="1.0" encoding="UTF-8"?>
        <Package xmlns="http://soap.sforce.com/2006/04/metadata">
        """

        def metadataItems = [:]
        changedFiles.each { file ->
            def parts = file.split("/")
            if (parts.size() > 3) {
                def folder = parts[2]  // "classes", "triggers", etc.
                def name = parts.last().replaceAll("\\..*", "")  // Remove file extension

                if (metadataMap.containsKey(folder)) {
                    def metadataType = metadataMap[folder]
                    if (!metadataItems.containsKey(metadataType)) {
                        metadataItems[metadataType] = []
                    }
                    metadataItems[metadataType] << name
                }
            }
        }

        metadataItems.each { type, members ->
            packageXml += "    <types>\n"
            members.unique().each { member ->
                packageXml += "        <members>${member}</members>\n"
            }
            packageXml += "        <name>${type}</name>\n"
            packageXml += "    </types>\n"
        }

        packageXml += "    <version>63.0</version>\n</Package>"

        writeFile(file: "manifest/package.xml", text: packageXml)
        println "Generated package.xml:\n${packageXml}"
    }

    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
        stage('Check for Conflicts') {
            def rc = bat returnStatus: true, script: "\"${toolbelt}\" project deploy start --manifest manifest/package.xml --target-org ${HUB_ORG} --dry-run"
            if (rc != 0) { 
                println 'Conflicts detected! Overwriting remote changes with Git source...'
            } else {
                println 'No conflicts detected.'
            }
        }
    }

    withCredentials([file(credentialsId: QA_JWT_KEY_CRED_ID, variable: 'qa_jwt_key_file')]) {
        stage('Deploy to QA Org (Ignoring Conflicts)') {
            def rc = bat returnStatus: true, script: "\"${toolbelt}\" org login jwt --client-id ${QA_CONNECTED_APP_CONSUMER_KEY} --username ${QA_HUB_ORG} --jwt-key-file \"${qa_jwt_key_file}\" --instance-url ${QA_SFDC_HOST}"
            if (rc != 0) { 
                error 'QA org authorization failed' 
            }

            println "QA Org Authorization successful, proceeding with QA deployment."

            def rmsg = bat returnStdout: true, script: "\"${toolbelt}\" project deploy start --manifest manifest/package.xml --target-org ${QA_HUB_ORG} --ignore-conflicts"
            println "QA Deployment Output:\n${rmsg}"
        }
    }
}
