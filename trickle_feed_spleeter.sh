#!/bin/bash
set -x
SLEEP=100 #seconds
TIME=$(date +"%T")

UPLOAD_DIR=/mnt/split-tmp-download-bucket-1/
if [ -d "$1" ]; then
    ### Take action if $DOWNLOAD_DIR exists ###
    echo "${TIME}: Comitting to split" >> /var/log/messages
    wait
    source /root/miniconda3/bin/conda.sh
    wait
    conda activate spleeter-cpu
    wait

    bash ./tools/user_check.sh
    cd $1 || exit 
    for file in $(ls /mnt/split-tmp-upload-bucket-1/single_split_test1/ | grep .mp3); do spleeter separate -i '/mnt/split-tmp-upload-bucket-1/single_split_test1/'${file} -o $UPLOAD_DIR -p spleeter:2stems; wait; done
    echo -e "${TIME}: SPLIT COMPLETE: WAITING FOR OUTPUT" >> /var/log/messages

else
    echo "${TIME}: CRITICAL: $1 not found. Can not continue." >> /var/log/messages
    exit 1
fi

sync_to_s3(){
	cd /opt/sudjsoc-spleeter/ || exit 
	./sync_to_s3.sh "$(ls /mnt/split-tmp-download-bucket-1/ | grep -v 'models')"
}

sync_to_s3
set +x

