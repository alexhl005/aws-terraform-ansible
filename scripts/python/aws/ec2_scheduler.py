#!/usr/bin/env python3
import boto3
import sys
import logging
from datetime import datetime

logging.basicConfig(
    filename='/var/log/ec2_scheduler.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def manage_instances(action):
    ec2 = boto3.client('ec2')
    filters = [{'Name': 'tag:AutoSchedule', 'Values': ['true']}]
    
    if action == 'start':
        instances = ec2.describe_instances(Filters=filters + [
            {'Name': 'instance-state-name', 'Values': ['stopped']}
        ])
        ec2.start_instances(InstanceIds=get_instance_ids(instances))
        logging.info(f"Iniciadas instancias: {get_instance_ids(instances)}")
    elif action == 'stop':
        instances = ec2.describe_instances(Filters=filters + [
            {'Name': 'instance-state-name', 'Values': ['running']}
        ])
        ec2.stop_instances(InstanceIds=get_instance_ids(instances))
        logging.info(f"Detenidas instancias: {get_instance_ids(instances)}")

def get_instance_ids(instances):
    return [i['InstanceId'] for r in instances['Reservations'] for i in r['Instances']]

if __name__ == "__main__":
    if len(sys.argv) != 2 or sys.argv[1] not in ['start', 'stop']:
        print("Uso: ec2_scheduler.py [start|stop]")
        sys.exit(1)
    
    manage_instances(sys.argv[1])