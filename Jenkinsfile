pipeline {
    agent any
    
    stages {
        stage('Zip Lambda Code') {
            steps {
                sh 'zip terraform/function.zip lambda_function.py'
            }
        }

        stage('Apply Terraform') {
            steps {
                sh '''
                    cd terraform
                    terraform init
                    terraform import aws_api_gateway_stage.default_stage mj92zct6nc/default
                    terraform apply -auto-approve
                '''
            }
        }
    }
}
