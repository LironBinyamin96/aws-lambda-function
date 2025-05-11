pipeline {
    agent any
    environment {
        AWS_REGION = "il-central-1"
        FUNCTION_NAME = "liron-lambda-new"
    }
    
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
