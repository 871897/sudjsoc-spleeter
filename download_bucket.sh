#!/bin/bash

echo `date`

download_bucket_contents(){
	echo "Downloading bucket"
	aws s3 sync s3://spleeter-splitting /mnt/spleeter-readable
	echo "Done"
}
	
download_bucket_contents
