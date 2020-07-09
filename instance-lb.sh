#!/bin/bash

TIME=$(date +"%T")
DATE=$(echo `date`)
REGION=eu-west-2
TG_ARN=arn:aws:elasticloadbalancing:eu-west-2:948686707161:targetgroup/core-sudjsoc-tg/78032aef615eb413


instance_id(){
	echo "${TIME}: Getting instance id" >> /var/log/messages
	instance_id=$(curl http://169.254.169.254/1.0/meta-data/instance-id)
	echo "${TIME}: instance id: ${instance_id}" >> /var/log/messages
}

private_ip(){
	echo "${TIME}: Finding public ip"
	public_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
	echo "${TIME}: Public ip: ${public_ip}" >> /var/log/messages
}


tg_arn(){
	echo "${TIME}: Finding load balancer" >> /var/log/messages
	lb_output=$(aws elbv2 describe-target-groups --target-group-arns ${TG_ARN} --output text | awk '{print $2}' | grep 'arn')
	#aws elbv2 describe-target-groups --names ${TG_NAME} --output list --region ${REGION})
	echo "${TIME}: ${lb_output}" >> /var/log/messages
}

assign_instance_to_lb(){
	echo "${TIME}: Registering instance to target group: ${TG_ARN}" >> /var/log/messages
	assignment_output=$(aws elbv2 register-targets --target-group-arn ${TG_ARN} --targets Id=${public_ip})
}


main(){
	instance_id
	private_ip
	target_arn
	assign_instance_to_lb
}

main
