import boto3
import os

# Retrieve environment variables
EIP = os.environ['EIP']
ACTIVE_INSTANCE = os.environ['ACTIVE_INSTANCE']
PASSIVE_INSTANCE = os.environ['PASSIVE_INSTANCE']

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')

    try:
        # Get current EIP association
        addresses = ec2.describe_addresses(PublicIps=[EIP])
        allocation_id = addresses['Addresses'][0]['AllocationId']
        current_instance = addresses['Addresses'][0].get('InstanceId', None)

        print(f"Current EIP association: {current_instance}")
        print(f"Active instance: {ACTIVE_INSTANCE}")
        print(f"Passive instance: {PASSIVE_INSTANCE}")

        # Check the state of the currently associated instance (if any)
        if current_instance:
            instance_response = ec2.describe_instances(InstanceIds=[current_instance])
            current_instance_state = instance_response['Reservations'][0]['Instances'][0]['State']['Name']
            print(f"Current instance state: {current_instance_state}")
        else:
            current_instance_state = None

        # Check the state of the active instance
        active_instance_response = ec2.describe_instances(InstanceIds=[ACTIVE_INSTANCE])
        active_instance_state = active_instance_response['Reservations'][0]['Instances'][0]['State']['Name']
        print(f"Active instance state: {active_instance_state}")

        # Failover logic
        if active_instance_state != "running" or current_instance_state != "running":
            print("Active instance is not running or EIP is not correctly associated. Triggering failover.")
            ec2.associate_address(
                AllocationId=allocation_id,
                InstanceId=PASSIVE_INSTANCE,
                AllowReassociation=True
            )
            print(f"EIP reassigned to passive instance: {PASSIVE_INSTANCE}")
        else:
            print("EIP is associated with the active instance in a running state. No action required.")
    except Exception as e:
        print(f"Error during failover: {e}")
        raise e
