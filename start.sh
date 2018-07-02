#!/bin/bash

# Create infrastructure. This also changes the python IP in the node app so that they can communicate
# The -auto-approve flag makes it not to ask for plan approval. Use at your own risk!
echo "##### Applying terraform infrastructure #####"
~/terraform apply -auto-approve

# Once the infrastructure is created, the node process are running (The node_user_data.sh is run when
# applying the infrastructure, that is the one that starts that process) but the python one no.
# So, it's important to start it in the appropiate server:
echo "##### Starting python app #####"
cd python && ./start

# Since now, all the commands are executed within the node folder
cd ../node

# The node code that is actually running has a wrong python server URL, so we must zip it again with the
# correct IP that has been changed when applying the python.tf infrastructure
echo "##### Zipping node source code #####"
./zip
# And we must upload the src.zip file to the S3 bucket (Which name is in TP_ARQUI_S3_BUCKET env var) by using the aws-cli.
echo "##### Uploading node source code to S3 bucket #####"
aws s3 cp src.zip "s3://$(cat source_location)/src.zip" --profile terraform

# By using the aws-cli, we get the node server IPs, so that we can update their code with the zip file.
# Of course you can also get this data from the EC2 console under the name "IPv4 Public IP".
# This command returns a tab-separated string with the IPs, so we transform them to end-lines
# Note that we are using a profile called terraform for the aws-cli
echo "##### Getting node instances IPs #####"
aws ec2 describe-instances --profile terraform --query "Reservations[*].Instances[*].PublicIpAddress" --filters "Name=tag-value,Values=tp_arqui_node_asg_instance" --output=text | tr '\t' '\n' > ips

# Finally, with those IPs, we update the node instances code with the src code uploaded to S3
# The "3" indicates the file descriptor to run that loop, so that it doesn't intercede with stdin
while IFS='' read -r ip <&3 || [[ -n "$ip" ]]; do
    echo "##### Updating node source code of instance with IP $ip #####"
    ./update "$ip"
done 3< ips

# Go away from node folder
cd ..
