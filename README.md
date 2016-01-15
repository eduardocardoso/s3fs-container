# s3fs-container
This repository contains the files necessary to build a docker container that mounts an Amazon S3 bucket and exports it as an NFS share for local read/write access. It it based on Debian Wheezy, and includes https://github.com/s3fs-fuse/s3fs-fuse and the Linux kernel NFS server.

## Use without docker
If you don't want to use docker to achieve this, just look at _run.sh_ and steal the ideas. If you just want to mount the bucket on one machine and don't need NFS, just use https://github.com/s3fs-fuse/s3fs-fuse.

## Acknowledgements
This repository was forked from https://github.com/eduardocardoso/s3fs-container, he did all the hard work.

## Usage
1. Set up an S3 bucket, and get an AWS ID/KEY pair that has access to it.
2. Run an instance of this container:
```
docker run -d --cap-add SYS_ADMIN -e AWS_ID=<AWS-id> -e AWS_KEY=<AWS-key> -e BUCKET=<bucket-name> --name=s3fs realflash/s3fs-nfs
```
_<bucket-name>_ in this case is the name you chose; you don't need the full AWS URI.

## Example S3 policy
You should use AWS' IAM feature to set up a user that only has access to the bucket you want this container to share, and get an ID/key pair for that user. Then if the ID/key pair are ever compromised, an attacker only has access to one bucket, not your whole AWS account. Here's the security policy I attach to my bucket user:
```
{
  "Statement": [
    {
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": [
            "arn:aws:s3:::bucket-name",
            "arn:aws:s3:::bucket-name/*"
        ]
    }
  ]
}
```
