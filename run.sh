#!/bin/sh -v

# -----------------------------------------------------------------
# Configure the AWS CLI to let it communicate with your account
# -----------------------------------------------------------------
aws configure set aws_access_key_id $ACCESS_KEY_ID
aws configure set aws_secret_access_key $SECRET_ACCESS_KEY
aws configure set region us-east-1

# -----------------------------------------------------------------
# Deploying a Lambda Function requires two steps.
# -----------------------------------------------------------------
# 1. Create a deployment ZIP file and upload it to S3
# 2. Deploy the CloudFormation template that picks this ZIP file and makes a Lambda function
#
# The below code will do both

# -----------------------------------------------------------------
# Cleanup anything that is left over from the last deployment.
# -----------------------------------------------------------------
rm -f *.zip 

# -----------------------------------------------------------------
# Create a unique S3 Bucket. The name of S3 bucket is derived from the access key. So it has to be unique
# -----------------------------------------------------------------
bucket=`echo $ACCESS_KEY_ID | tr '[:upper:]' '[:lower:]'`
aws s3 mb s3://educative.${bucket} --region us-east-1

# -----------------------------------------------------------------
# It is important that this zip file has a new name everytime we deploy. Else, the new code is not picked.
# We start by creating a random string. This is an important part of CloudFormation deployments.
# -----------------------------------------------------------------
RAND=$(dd if=/dev/random bs=8 count=1 2>/dev/null | od -An -tx1 | tr -d ' \t\n')

# -----------------------------------------------------------------
# Build the zip file that we want to deploy. At this point, we include the index.js in our 
# -----------------------------------------------------------------
zip -r ${RAND}.zip index.js

# -----------------------------------------------------------------
# Upload the lambda zip file to the S3 bucket. 
# -----------------------------------------------------------------
aws s3 cp ${RAND}.zip s3://educative.${bucket}

# -----------------------------------------------------------------
# With everything ready, we initiate the CloudFormation deployment.
# -----------------------------------------------------------------
aws cloudformation deploy \
    --template-file template.yml \
    --stack-name EducativeCourseApiGateway \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides DeployId="$RAND" SourceCodeBucket="educative.${bucket}" \
    --region us-east-1

# -----------------------------------------------------------------
# To test the Lambda Function, find out the URL of our Lambda Function
# -----------------------------------------------------------------
url=`aws lambda get-function-url-config --function-name EducativeHelloWorld --region us-east-1 | jq -r ".FunctionUrl"`

# -----------------------------------------------------------------
# Invoke the Lambda Function URL using curl
# -----------------------------------------------------------------
echo $url
curl $url


