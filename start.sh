#!/bin/bash

# Create infrastructure. This also changes the python IP and the redis DNS in the node app so that they can communicate
echo "##### Applying terraform infrastructure #####"
~/terraform apply -auto-approve

# Start the python app that is not started in the terraform apply command
echo "##### Starting python app #####"
cd python && ./start

cd ../node

# Get node instances IPs with the AWS CLI. It returns a tab-separated string with the IPs, so we transform them to end-lines
echo "##### Getting node instances IPs #####"
aws ec2 describe-instances --profile terraform --query "Reservations[*].Instances[*].PublicIpAddress" --filters "Name=tag-value,Values=tp_arqui_node_asg_instance" --output=text | tr '\t' '\n' > ips

# Zip the source code of the node apps with the correct python IP
echo "##### Zipping node source code #####"
./zip
echo "##### Uploading node source code to S3 bucket #####"
aws s3 cp src.zip s3://tp-arquitecturas/src.zip --profile terraform

# Update the node instances code with the src code uploaded to S3
while IFS='' read -r ip <&3 || [[ -n "$ip" ]]; do
    echo "##### Updating node source code of instance with IP $ip #####"
    ./update "$ip"
done 3< ips

cd ..