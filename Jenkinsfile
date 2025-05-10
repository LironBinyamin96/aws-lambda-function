pipeline {
    agent any
    environment {
        AWS_REGION = "il-central-1"
        FUNCTION_NAME = "liron-lambda-jenkins"
    }
    stages {

        stage('Zip Lambda Code') {
            steps {
                sh 'zip function.zip lambda_function.py'
            }
        }

        stage('Update Lambda') {
            steps {
                sh '''
                    aws lambda update-function-code \
                      --function-name $FUNCTION_NAME \
                      --zip-file fileb://function.zip \
                      --region $AWS_REGION
                '''
            }
        }
    }
}
