//Declarative Pipeline
def VERSION='1.0.0'
pipeline {
    agent none
    environment {
        PROJECT = "WELCOME TO DEVOPS B28 BATCH - Jenkins Class"
    }
    stages {
     stage('For Parallel Stages') {
      parallel {
        stage('Deploy To Development') {
            agent { label 'DEV' }
            environment {
            DEVDEFAULTAMI = "ami-075c86380172ae621"
            PACKER_ACTION = "YES" //YES or NO
            TERRAFORM_APPLY = "NO" //YES or NO
            ANSIBLE_ACTION = "NO" //YES or NO
            TERRAFORM_DESTROY = "YES" //YES or NO
            }
            when {
                branch 'development'
            }
            stages {
                stage('Perform Packer Build') {
                    when {
                        expression {
                            "${env.PACKER_ACTION}" == 'YES'
                        }
                    }
                    steps { //Assume Role in SreeMasterAccount AWS Account
                        withAWS(role:'DevOpsB28JenkinsAssumeRole', roleAccount:'053490018989', duration: 900, roleSessionName: 'jenkins-session') {
                            sh 'pwd'
                            sh 'ls -al'
                            sh 'packer build -var-file packer-vars-dev.json packer.json | tee output.txt'
                            sh "tail -2 output.txt | head -2 | awk 'match(\$0, /ami-.*/) { print substr(\$0, RSTART, RLENGTH) }' > ami.txt"
                            sh "echo \$(cat ami.txt) > ami.txt"
                            script {
                                def AMIID = readFile('ami.txt').trim()
                                sh 'echo "" >> variables.tf'
                                sh "echo variable \\\"imagename\\\" { default = \\\"$AMIID\\\" } >> variables.tf"
                            }
                        }
                    }
                }
                stage('No Packer Build') {
                    when {
                        expression {
                            "${env.PACKER_ACTION}" == 'NO'
                        }
                    }
                    steps {
                        script {
                        echo VERSION //Passing Variable From Top
                        VERSION = "2.0.0";
                        }
                        sh 'pwd'
                        sh 'ls -al'
                        sh 'echo "" >> variables.tf'
                        sh "echo variable \\\"imagename\\\" { default = \\\"${env.DEVDEFAULTAMI}\\\" } >> variables.tf"
                    }
                }
                stage('Terraform Plan') {
                    when {
                        expression {
                            "${env.TERRAFORM_APPLY}" == 'YES'
                        }
                    }
                    steps {
                        withAWS(role:'DevOpsB28JenkinsAssumeRole', roleAccount:'053490018989', duration: 900, roleSessionName: 'jenkins-session') {
                            script {
                            echo VERSION
                            }
                            sh 'rm -rf .terraform'
                            sh 'rm -f prod-backend.tf'
                            sh 'terraform init'
                            sh 'terraform validate'
                            sh 'terraform plan'
                        }
                    }
                }
                stage('Terraform Apply') {
                    when {
                        expression {
                            "${env.TERRAFORM_APPLY}" == 'YES'
                        }
                    }
                    steps {
                        withAWS(role:'DevOpsB28JenkinsAssumeRole', roleAccount:'053490018989', duration: 900, roleSessionName: 'jenkins-session') {
                            sh 'rm -rf .terraform'
                            sh 'terraform init'
                            sh 'terraform apply --auto-approve'
                        }
                    }
                }
                stage('Validate Ansible Playbook & Dry Run') {
                    when {
                        expression {
                            "${env.ANSIBLE_ACTION}" == 'YES'
                        }
                    }
                    steps {
                        sh 'sleep 15'
                        sh 'ansible-playbook -i invfile docker-swarm.yml --syntax-check'
                        //Used withCredentials for dry-run as ansible plugin dont have --check option.
                        withCredentials([file(credentialsId: 'LaptopKey', variable: 'ansiblepvtkey')]) {
                        sh "sudo cp \$ansiblepvtkey $WORKSPACE"
                        sh "ls -al"
                        sh "sudo ansible-playbook -i invfile docker-swarm.yml -u ansibleadmin --private-key=LaptopKey.pem --check"
                        }
                          
                    }
                }
                stage('Run Ansible Playbook') {
                    when {
                        expression {
                            "${env.ANSIBLE_ACTION}" == 'YES'
                        }
                    }
                    steps {
                        //sh 'ansible-playbook -i invfile docker-swarm.yml -u ansibleadmin --private-key=/var/lib/jenkins/logs/ansibleadminkey -vv'
                        ansiblePlaybook credentialsId: 'ansibleadmin', disableHostKeyChecking: true, installation: 'Ansible', inventory: 'invfile', playbook: 'docker-swarm.yml'  
                    }
                }
                stage('Terraform Destroy') {
                    when {
                        expression {
                            "${env.TERRAFORM_DESTROY}" == 'YES'
                        }
                    }
                    steps {
                        withAWS(role:'DevOpsB28JenkinsAssumeRole', roleAccount:'053490018989', duration: 900, roleSessionName: 'jenkins-session') {
                            sh 'rm -f prod-backend.tf'
                            sh 'terraform init'
                            sh 'terraform destroy --auto-approve'
                        }
                    }
                }
            }
        post {
            success {
                echo 'Development Pipeline Is Success.'
            }
            failure {
                echo 'Development Pipeline Is Failed With Errors.'
            }
            cleanup {
                echo 'This Will Run always Development Pipeline.'
            }
        }
        }
        stage('Deploy To Production') {
            agent { label 'PROD' }
            environment {
            PRODEFAULTAMI = "ami-0e37f15b60de3da17"
            PACKER_ACTION = "NO" //YES or NO
            TERRAFORM_APPLY = "NO" //YES or NO
            TERRAFORM_DESTROY = "YES" //YES or NO
            ANSIBLE_ACTION = "NO" //YES or NO
            }
            when {
                branch 'production'
            }
            stages {
                stage('Perform Packer Build') {
                    when {
                        expression {
                            "${env.PACKER_ACTION}" == 'YES'
                        }
                    }
                    steps { //Assume Role in SREEK8S AWS Account
                        withAWS(role:'DevOpsB28JenkinsAssumeRole', roleAccount:'009412611595', duration: 900, roleSessionName: 'jenkins-session') {
                            echo "${env.BUILD_NUMBER}" //Accessing env variable way 1
                            sh "echo $BUILD_NUMBER" //Accessing env variable way 2
                            sh 'pwd'
                            sh 'ls -al'
                            sh 'packer build -var-file packer-vars-prod.json packer.json | tee output.txt'
                            sh "tail -2 output.txt | head -2 | awk 'match(\$0, /ami-.*/) { print substr(\$0, RSTART, RLENGTH) }' > ami.txt"
                            sh "echo \$(cat ami.txt) > ami.txt"
                            script {
                                def AMIID = readFile('ami.txt').trim()
                                sh 'echo "" >> variables.tf'
                                sh "echo variable \\\"imagename\\\" { default = \\\"$AMIID\\\" } >> variables.tf"
                            }
                        }
                    }
                }
                stage('No Packer Build') {
                    when {
                        expression {
                            "${env.PACKER_ACTION}" == 'NO'
                        }
                    }
                    steps {
                        sh 'pwd'
                        sh 'ls -al'
                        sh 'echo "" >> variables.tf'
                        sh "echo variable \\\"imagename\\\" { default = \\\"${env.PRODEFAULTAMI}\\\" } >> variables.tf"
                    }
                }
                stage('Terraform Plan') {
                    when {
                        expression {
                            "${env.TERRAFORM_APPLY}" == 'YES'
                        }
                    }
                    steps {
                        withAWS(role:'DevOpsB28JenkinsAssumeRole', roleAccount:'009412611595', duration: 900, roleSessionName: 'jenkins-session') {
                            sh 'rm -rf .terraform'
                            sh 'rm -f dev-backend.tf'
                            sh 'terraform init'
                            sh 'terraform validate'
                            sh 'terraform plan'
                        }
                    }
                }
                stage('Terraform Apply') {
                    when {
                        expression {
                            "${env.TERRAFORM_APPLY}" == 'YES'
                        }
                    }
                    steps {
                        withAWS(role:'DevOpsB28JenkinsAssumeRole', roleAccount:'009412611595', duration: 900, roleSessionName: 'jenkins-session') {
                            sh 'rm -rf .terraform'
                            sh 'terraform init'
                            sh 'terraform apply --auto-approve'
                        }
                    }
                }
                stage('Validate Ansible Playbook & Dry Run') {
                    when {
                        expression {
                            "${env.ANSIBLE_ACTION}" == 'YES'
                        }
                    }
                    steps {
                        sh 'sleep 15'
                        sh 'ansible-playbook -i invfile docker-swarm.yml --syntax-check'
                        //Used withCredentials for dry-run as ansible plugin dont have --check option.
                        withCredentials([file(credentialsId: 'LaptopKey', variable: 'ansiblepvtkey')]) {
                        sh "sudo cp \$ansiblepvtkey $WORKSPACE"
                        sh "ls -al"
                        sh "sudo ansible-playbook -i invfile docker-swarm.yml -u ansibleadmin --private-key=LaptopKey.pem --check"
                        }
                          
                    }
                }
                stage('Run Ansible Playbook') {
                    when {
                        expression {
                            "${env.ANSIBLE_ACTION}" == 'YES'
                        }
                    }
                    steps {
                        //sh 'ansible-playbook -i invfile docker-swarm.yml -u ansibleadmin --private-key=/var/lib/jenkins/logs/ansibleadminkey -vv'
                        ansiblePlaybook credentialsId: 'ansibleadmin', disableHostKeyChecking: true, installation: 'Ansible', inventory: 'invfile', playbook: 'docker-swarm.yml'  
                    }
                }
                stage('Terraform Destroy') {
                    when {
                        expression {
                            "${env.TERRAFORM_DESTROY}" == 'YES'
                        }
                    }
                    steps {
                        withAWS(role:'DevOpsB28JenkinsAssumeRole', roleAccount:'009412611595', duration: 900, roleSessionName: 'jenkins-session') {
                            sh 'rm -f dev-backend.tf'
                            sh 'terraform init'
                            sh 'terraform destroy --auto-approve'
                            //sh 'false' //This will fail the stage.
                        }
                    }
                }
            }
        post {
            success {
                echo 'Production Pipeline Is Success'
            }
            failure {
                echo 'Production Pipeline Is Failed With Errors'
            }
            cleanup {
                echo 'This Will Run always in Production Pipeline.'
            }
        }
        }

      }
    }
  }
}
