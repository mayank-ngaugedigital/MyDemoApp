import groovy.json.JsonSlurperClassic

node {
    def BUILD_NUMBER = env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR = "tests/${BUILD_NUMBER}"
    def HUB_ORG = env.HUB_ORG_DH
    def SFDC_HOST = env.SFDC_HOST_DH
    def JWT_KEY_CRED_ID = env.JWT_CRED_ID_DH
    def CONNECTED_APP_CONSUMER_KEY = env.CONNECTED_APP_CONSUMER_KEY_DH
    def GIT_BRANCH = "main"
    def GIT_REPO_URL = "https://github.com/mayank-ngaugedigital/MyDemoApp"
    def toolbelt = "C:/Program Files/sf/bin/sfdx.cmd"

    stage('Checkout Source from Git') {
        checkout([
            $class: 'GitSCM',
            branches: [[name: GIT_BRANCH]],
            userRemoteConfigs: [[url: GIT_REPO_URL]]
        ])
    }

    stage('Detect Changed Files') {
        def changedFiles = sh(script: "git diff --name-only HEAD~1 HEAD", returnStdout: true).trim().split("\n")
        def metadataMap = [
            "classes": "ApexClass",
            "triggers": "ApexTrigger",
            "pages": "ApexPage",
            "components": "ApexComponent",
            "aura": "AuraDefinitionBundle",
            "lwc": "LightningComponentBundle",
            "staticresources": "StaticResource"
        ]

        def packageXmlContent = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Package xmlns="http://soap.sforce.com/2006/04/metadata">
        """

        def metadataToDeploy = [:]

        changedFiles.each { file ->
            def parts = file.split("/")
            if (parts.length > 1) {
                def folder = parts[0]
                def name = parts[1].replace(".cls", "").replace(".trigger", "").replace(".page", "").replace(".component", "").replace(".resource", "")
                if (metadataMap.containsKey(folder)) {
                    if (!metadataToDeploy.containsKey(metadataMap[folder])) {
                        metadataToDeploy[metadataMap[folder]] = []
                    }
                    metadataToDeploy[metadataMap[folder]].add(name)
                }
            }
        }

        metadataToDeploy.each { type, members ->
            packageXmlContent += """
            <types>
                ${members.collect { "<members>${it}</members>" }.join("\n")}
                <name>${type}</name>
            </types>
            """
        }

        packageXmlContent += "<version>63.0</version>\n</Package>"

        writeFile file: 'manifest/package.xml', text: packageXmlContent

        echo "Updated package.xml with changed files:\n${packageXmlContent}"
    }

    stage('Deploy Changed Files') {
        withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
            def rc = bat returnStatus: true, script: "\"${toolbelt}\" project deploy start --manifest manifest/package.xml --target-org ${HUB_ORG}"
            if (rc != 0) { error "Deployment failed" }
        }
    }
}
