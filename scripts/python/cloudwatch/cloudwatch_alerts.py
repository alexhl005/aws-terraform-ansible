#!/usr/bin/env python3
import boto3
import psutil
from datetime import datetime

cloudwatch = boto3.client('cloudwatch')
INSTANCE_ID = open('/var/lib/cloud/data/instance-id').read().strip()

def report_metrics():
    # CPU
    cpu_usage = psutil.cpu_percent(interval=1)
    
    # Memory
    mem = psutil.virtual_memory()
    mem_usage = mem.percent
    
    # Disk
    disk = psutil.disk_usage('/')
    disk_usage = disk.percent
    
    # Network
    net_io = psutil.net_io_counters()
    net_in = net_io.bytes_recv
    net_out = net_io.bytes_sent
    
    metrics = [
        {
            'MetricName': 'CPUUtilization',
            'Value': cpu_usage,
            'Unit': 'Percent'
        },
        {
            'MetricName': 'MemoryUtilization',
            'Value': mem_usage,
            'Unit': 'Percent'
        },
        {
            'MetricName': 'DiskSpaceUtilization',
            'Value': disk_usage,
            'Unit': 'Percent'
        },
        {
            'MetricName': 'NetworkIn',
            'Value': net_in,
            'Unit': 'Bytes'
        },
        {
            'MetricName': 'NetworkOut',
            'Value': net_out,
            'Unit': 'Bytes'
        }
    ]
    
    cloudwatch.put_metric_data(
        Namespace='Custom/EC2',
        MetricData=[{
            **metric,
            'Dimensions': [{
                'Name': 'InstanceId',
                'Value': INSTANCE_ID
            }],
            'Timestamp': datetime.utcnow()
        } for metric in metrics]
    )

if __name__ == "__main__":
    report_metrics()