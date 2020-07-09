#!/bin/bash
set -x
DATE==$(echo `date`)
REGION=eu-west-2
BUCKET_ROLE=split-tmp-upload-bucket
TIME=$(date +"%T")

create_temp_bucket(){
  	export COUNTER=$((COUNTER+1))
  	echo "${TIME}: Creating users temporary bucket" >> /var/log/messages
  	aws s3 mb s3://${BUCKET_ROLE}-${COUNTER} --region $REGION
  	echo "${TIME}: Temporary bucket created, ready for end user" >> /var/log/messages
}

sync_bucket_contents_down(){
	echo "${TIME}: Syncing from temporary bucket" >> /var/log/messages
	aws s3 sync s3://${BUCKET_ROLE}-${COUNTER}/  /mnt/${BUCKET_ROLE}-${COUNTER}
	wait
	echo "${TIME}: Sync complete" >> /var/log/messages
}

format_sync_directory(){
	echo "${TIME}: Formatting sync directory" >> /var/log/messages
	cd /mnt/${BUCKET_ROLE}-${COUNTER} || exit
	formatted_dir=$(ls /mnt/${BUCKET_ROLE}-${COUNTER}/ | grep single_split)
	mv * $formatted_dir
	echo "${TIME}: Sync directory formatting complete" >> /var/log/messages
}	

trickle_feed_spleeter(){
  	echo "${TIME}: Activating splitting script..." >> /var/log/messages
	cd /opt/sudjsoc-spleeter/
  	bash trickle_feed_spleeter.sh /mnt/split-tmp-upload-bucket-1/single_split_test${COUNTER}/
}

read_counter_file(){
  	export COUNTER=$(cat /var/www/website/counter.txt)
} 

update_counter_file(){
	COUNTER=$((COUNTER+1))
  	echo $COUNTER > /var/www/website/counter.txt
}

main(){
	read_counter_file
	if	[ -v $COUNTER ]; then
		echo "${TIME}: CRITICAL: Bucket counter not identified." >> /var/log/messages && exit 1

	else
		echo "${TIME}: Latest bucket found, generating temp directory and uploading contents..." >> /var/log/messages
		sync_bucket_contents_down
	       	format_sync_directory
		wait
		trickle_feed_spleeter
		wait
	fi
}

main
set +x
