#!/bin/sh

function usage() {
  echo "$0 (start|stop|status)i instance_id ec2_region"
}

if [ $# -ne 3 ]; then
  usage
  exit 2
fi

DEBUG="echo "
DEBUG=""

INSTANCE_ID=$2
REGION=$3

INSTANCE_STS=`aws ec2 describe-instance-status --region $REGION --instance-ids $INSTANCE_ID | jq -r '.InstanceStatuses[].InstanceState.Name'`

echo "InstanceStatus : [$INSTANCE_STS]"

EXIT=0
if [ "$1" = "start" ]; then
  if [ "$INSTANCE_STS" = "running" ]; then
    echo "instance is already running."
  else
    echo "start instance..."
    $DEBUG aws ec2 start-instances --instance-ids $INSTANCE_ID --region $REGION
    EXIT=$?
  fi
elif [ "$1" = "stop" ]; then
  if [ "$INSTANCE_STS" = "running" ]; then
    echo "stop instance..."
    $DEBUG aws ec2 stop-instances --instance-ids $INSTANCE_ID --region $REGION
    EXIT=$?
  else
    echo "instance is already stopped"
  fi
elif [ "$1" = "status" ]; then
  echo "Status Check only."
else
  usage
  EXIT=2
fi
