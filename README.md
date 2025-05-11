# Lambda Function Deployment with Jenkins
## 📝 Project Description
This project includes an AWS Lambda function designed to store and retrieve data from DynamoDB. By default, the table used is named imtech (as in my setup), but you can change it to any other table name as needed. The function is written in Python, supports HTTP POST and GET methods, and is managed via a Jenkins Pipeline that automatically deploys updated code to AWS.

## 📁 Project Structure
lambda_function.py – The Lambda function that handles HTTP requests and interacts with DynamoDB.

Jenkinsfile – Jenkins Pipeline file that zips the code and updates the Lambda function on AWS.

## 🚀 Functionality
Lambda – lambda_function.py
The function performs the following actions:

### ✅ POST
Expects a request with a JSON body.

Stores the content under the key id=some-id in a DynamoDB table.

In my case, the table name is imtech, but you can change it by modifying this line:

python
Copy
Edit
table = dynamodb.Table('imtech')
Returns status 200 with a success message.

### ✅ GET
Retrieves data for the key id=some-id from the DynamoDB table.

If found, returns the data as JSON.

If not found, returns status 404.

### ❌ Error Handling
Returns 400 if httpMethod is missing (e.g., if API Gateway is not using Lambda Proxy Integration).

Returns 500 if an internal error occurs.

Returns 405 if an unsupported HTTP method is used.

### 🔁 Jenkins Pipeline – Jenkinsfile
The pipeline has two main stages:

#### Zip Lambda Code
Packages lambda_function.py into a zip file called function.zip.

#### Update Lambda
Uploads the new code to the Lambda function named liron-lambda-jenkins in the AWS region il-central-1.

#### Requirements:
Jenkins must be configured with AWS credentials that have the required permissions.

AWS CLI must be installed and properly configured.

The Lambda function liron-lambda-jenkins must already exist in AWS.

## 🛠️ Deployment Tips
Make sure the DynamoDB table exists. In my case, it's named imtech, but you can choose any name—just ensure it matches the name in the code.

Use Lambda Proxy Integration in API Gateway so that httpMethod is passed correctly.
