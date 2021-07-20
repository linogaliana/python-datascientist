import os
import boto3
import glob
import re

s3 = boto3.client("s3",endpoint_url = "https://minio.lab.sspcloud.fr")

os.chdir("./python-datascientist")

list_notebooks = "./temp/course"
# root_dir needs a trailing slash (i.e. /root/dir/)
filenames = list(glob.iglob('./temp/course/**/*.ipynb', recursive=True))


def upload_minio(file, bucket = "lgaliana"):
    outname = re.sub("\./temp/course/","", file)
    s3.upload_file(file, bucket, "python-ENSAE/enonces/{}".format(outname))

[upload_minio(file = f) for f in filenames]
