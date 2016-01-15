# s3fs-container
This repository contains the files necessary to build a docker container that mounts an Amazon S3 bucket and exports it as an NFS share for local read/write access. It it based on Debian Wheezy, and includes https://github.com/s3fs-fuse/s3fs-fuse and the Linux kernel NFS server.

## Use without docker
If you don't want to use docker to achieve this, just look at _run.sh_ and steal the ideas. If you just want to mount the bucket on one machine and don't need NFS, just use https://github.com/s3fs-fuse/s3fs-fuse.

## Usage
1. Set up an S3 bucket, and get an AWS ID/KEY pair that has access to it.
2. Clone this repository and cd into it
3. Build this container:

    ```
    docker build -t yourname/s3fs-nfs .
    ```
4. On Linux machines you need to load the NFS kernel modules. Add the following to the bottom of _/etc/modules_ and reboot:

    ```
    nfs
    nfsd
    ```
    boot2docker on OSX contains NFS modules already so you can skip this step.
5. Run an instance of this container:

    ```
    docker run -d --cap-add SYS_ADMIN -e AWS_ID=<AWS-id> -e AWS_KEY=<AWS-key> -e BUCKET=<bucket-name> --name=s3fs yourname/s3fs-nfs
    ```
    _\<bucket-name\>_ in this case is the name you chose; you don't need the full AWS URI. This command returns an container ID.
6. Check the logs of the newly launched instance to confirm that the container has started OK:

    ```
    docker logs <container-ID>
    ```

## Troubleshooting
### fuse: failed to open /dev/fuse: Operation not permitted
On systems with AppArmor enabled (on by default in Ubuntu-derived distributions), you might see this error in the container logs. You will need additional flags when you launch the container. Stop your first container, delete it, and try again with:
```
docker run --device /dev/fuse --cap-add MKNOD ... (rest the same as above)
```
Depending upon your docker and Ubuntu version, even this may not be enough. Try:
```
docker run --privileged ...(rest the same as above)
``` 
Make sure you understand what --privileged does before you deploy it on a production machine.

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
