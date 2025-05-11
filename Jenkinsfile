pipeline {
    agent any
    
    stages {
        stage('Zip Lambda Code') {
            steps {
                sh 'zip function.zip lambda_function.py'
            }
        }

        stage('Apply Terraform') {
            steps {
                sh '''
                    cd terraform
                    terraform init
                    terraform apply -auto-approve
                '''
            }
        }
    }
}
