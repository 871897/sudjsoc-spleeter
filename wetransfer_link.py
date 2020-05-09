#!/usr/bin/python3

import time
import os
import logging
from wetransfer import TransferApi

# Setting up logging
logging.getLogger().setLevel(logging.INFO)

# Setting up



def upload_to_wetransfer():
        print('Executing s3fs mount now')
mount_cloud_storage()
