#!/bin/bash
echo "########### Setting region as env variable ##########"
export AWS_REGION=sa-east-1

echo "########### Setting up localstack profile ###########"
aws configure set aws_access_key_id access_key --profile=localstack
aws configure set aws_secret_access_key secret_key --profile=localstack
aws configure set region $AWS_REGION --profile=localstack

echo "########### Setting default profile ###########"
export AWS_DEFAULT_PROFILE=localstack

echo "########### Setting SQS names as env variables ###########"
export SQS_UPDATE_STORE_INVENTORY=SQS-QuantumTech-UpdateStoreInventory
export SQS_REGISTER_SALES=SQS-QuantumTech-RegisterSales

echo "########### Creating update store inventory SQS ###########"
aws --endpoint-url=http://localstack:4566 sqs create-queue --queue-name $SQS_UPDATE_STORE_INVENTORY

echo "########### ARN for update store inventory SQS ###########"
SQS_UPDATE_STORE_INVENTORY_ARN=$(aws --endpoint-url=http://localstack:4566 sqs get-queue-attributes\
                  --attribute-name QueueArn --queue-url=http://localhost:4566/000000000000/"$SQS_UPDATE_STORE_INVENTORY"\
                  |  sed 's/"QueueArn"/\n"QueueArn"/g' | grep '"QueueArn"' | awk -F '"QueueArn":' '{print $2}' | tr -d '"' | xargs)

echo "########### Creating register sales SQS ###########"
aws --endpoint-url=http://localstack:4566 sqs create-queue --queue-name $SQS_REGISTER_SALES

echo "########### ARN for register sales SQS ###########"
SQS_REGISTER_SALES_ARN=$(aws --endpoint-url=http://localstack:4566 sqs get-queue-attributes\
                  --attribute-name QueueArn --queue-url=http://localhost:4566/000000000000/"$SQS_REGISTER_SALES"\
                  |  sed 's/"QueueArn"/\n"QueueArn"/g' | grep '"QueueArn"' | awk -F '"QueueArn":' '{print $2}' | tr -d '"' | xargs)

echo "########### Listing queues ###########"
aws --endpoint-url=http://localhost:4566 sqs list-queues

echo "########### Setting S3 names as env variables ###########"
export S3_UPDATE_STORE_INVENTORY=update-store-inventory
export S3_REGISTER_SALES=register-sales

echo "########### Creating S3 buckets ###########"
aws --endpoint-url=http://localhost:4566 s3api create-bucket\
    --bucket $S3_UPDATE_STORE_INVENTORY --region $AWS_REGION\
    --create-bucket-configuration LocationConstraint=$AWS_REGION

aws --endpoint-url=http://localhost:4566 s3api create-bucket\
    --bucket $S3_REGISTER_SALES --region $AWS_REGION\
    --create-bucket-configuration LocationConstraint=$AWS_REGION

echo "########### Listing S3 buckets ###########"
aws --endpoint-url=http://localhost:4566 s3api list-buckets

echo "########### Setting S3 buckets notification configurations ###########"
aws --endpoint-url=http://localhost:4566 s3api put-bucket-notification-configuration\
    --bucket $S3_UPDATE_STORE_INVENTORY\
    --notification-configuration  '{
                                      "QueueConfigurations": [
                                         {
                                           "QueueArn": "'"$SQS_UPDATE_STORE_INVENTORY_ARN"'",
                                           "Events": ["s3:ObjectCreated:*"]
                                         }
                                       ]
                                     }'

aws --endpoint-url=http://localhost:4566 s3api put-bucket-notification-configuration\
    --bucket $S3_REGISTER_SALES\
    --notification-configuration  '{
                                      "QueueConfigurations": [
                                         {
                                           "QueueArn": "'"$SQS_REGISTER_SALES_ARN"'",
                                           "Events": ["s3:ObjectCreated:*"]
                                         }
                                       ]
                                     }'

echo "########### Get S3 bucket notification configurations ###########"
aws --endpoint-url=http://localhost:4566 s3api get-bucket-notification-configuration\
    --bucket $S3_UPDATE_STORE_INVENTORY

aws --endpoint-url=http://localhost:4566 s3api get-bucket-notification-configuration\
    --bucket $S3_REGISTER_SALES

echo "########### Command to view SQS messages ###########"
echo "aws --endpoint-url=http://localhost:4566 sqs receive-message --queue-url=http://localhost:4566/000000000000/SQS-QuantumTech-UpdateStoreInventory"
echo "aws --endpoint-url=http://localhost:4566 sqs receive-message --queue-url=http://localhost:4566/000000000000/SQS-QuantumTech-RegisterSales"