#!/bin/bash
set -x
DATE==$(echo `date`)
REGION=eu-west-2
BUCKET_ROLE=split-tmp-download-bucket
TIME=$(date +"%T")

#handle error if bucket created has the same random id generated.
#inside upload_bucket.php delete bucket after 30mins

get_latest_bucket_name(){
	echo "${TIME}: Searching S3 for latest bucket integer" >> /var/log/messages
	bucket_list=$(aws s3api list-buckets --query "Buckets[].Name" --region eu-west-2 | grep ${BUCKET_ROLE} | sort -nr | sed 's/"//g' | sed 's/,//g' )
	export latest_bucket=$(echo $bucket_list | awk '{print $1}')
	COUNTER=$(echo $latest_bucket | sed 's/split-tmp-upload-bucket-//g')
}

sync_bucket_contents_up(){
  	echo "${TIME}: Syncing to temporary bucket" >> /var/log/messages
	aws s3 sync "/mnt/split-tmp-download-bucket-1/$(ls /mnt/split-tmp-download-bucket-1/ | grep -v 'models')" s3://${BUCKET_ROLE}-${COUNTER}/
	echo "${TIME}: Sync complete" >> /var/log/messages
}

update_counter_file(){
	COUNTER=$((COUNTER+1))
  	echo $COUNTER > /var/www/website/counter.txt
}

read_counter_file(){
  	export COUNTER=$(cat /var/www/website/counter.txt)
}

cleanup(){
	echo -e "${TIME}: Cleaning up files for next run" >> /var/log/messages
	rm -rf /mnt/split-tmp-download-bucket-1/*
	echo -e "${TIME}: Cleanup complete" >> /var/log/messages
}

main(){
	read_counter_file
  	if	[ -v $COUNTER ]; then
		echo "${TIME}: CRITICAL: Bucket counter not identified." >> /var/log/messages && exit 1
 	else
	  	echo "${TIME}: Latest bucket ${BUCKET_ROLE}-${COUNTER} found, uploading contents..." >> /var/log/messages
	  	sync_bucket_contents_up
	  	#cleanup
	  	#update_counter_file
	fi
}

main
set +x
