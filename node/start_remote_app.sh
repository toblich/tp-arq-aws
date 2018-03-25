#!/bin/bash

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IP=`cat $DIR/node_ip_address.txt`

ssh -i $DIR/../key.pem ec2-user@$IP "node app &"
