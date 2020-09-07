#!/bin/sh

function usage() {
  echo "$0 ec2-config-file num_instances"
}

if [ $# -ne 2 ]; then
  usage
  exit 2
fi

CONFIG_FILE=$1
NUM_INSTANCES=$2

FILE_CONTENTS=`cat "$CONFIG_FILE"` 
echo "Json config file: " $FILE_CONTENTS

# Filename for logging
_nowDate=`date -u "+%Y%m%d-%H%M%S-%Z" | tr [A-Z] [a-z]`
_logsDir="${HOME}/Documents/awscli-logs"   
_logFile="awscli-ec2-create-$_nowDate.log"


# ec2 parameters
EC2_AMI=`cat "$CONFIG_FILE" | jq -r '.imageId'`
EC2_INSTANCE=`cat "$CONFIG_FILE" | jq -r '.instanceType'`
EC2_KEY=`cat "$CONFIG_FILE" | jq -r  '.keyName'`
EC2_SECURITY_GROUP_IDS=`cat "$CONFIG_FILE" | jq -r '.securityGroupIds'`
EC2_BLOCK_DEVICE_MAPPINGS=`cat "$CONFIG_FILE" | jq -r '.blockDeviceMappings'`
EC2_SUBNET_ID=`cat "$CONFIG_FILE" | jq -r '.subnetId'`
EC2_USER_DATA=`cat "$CONFIG_FILE" | jq -r '.userDataFile'`

ec2_id=$(aws ec2 run-instances --image-id $EC2_AMI  --count $NUM_INSTANCES --instance-type $EC2_INSTANCE --key-name $EC2_KEY --subnet-id $EC2_SUBNET_ID --block-device-mappings $EC2_BLOCK_DEVICE_MAPPINGS --associate-public-ip-address >> ${_logsDir}/${_logFile})

instance_id=$(cat ${_logsDir}/${_logFile} | grep InstanceId | cut -d":" -f2 | cut -d'"' -f2)
echo "Instance Id of EC2 launched is" $instance_id 

exit 0
