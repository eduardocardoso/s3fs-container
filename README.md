# s3fs-container
This repository contains the files necessary to build a docker container that mounts an Amazon S3 bucket and exports it as an NFS share for local read/write access. It it based on Debian Wheezy, and includes https://github.com/s3fs-fuse/s3fs-fuse and the Linux kernel NFS server. This is an [automated build](https://hub.docker.com/r/ecardoso/s3fs-nfs/) published to the [Docker Hub Registry](https://hub.docker.com/).

## Use without docker
If you don't want to use docker to achieve this, just look at _run.sh_ and steal the ideas. If you just want to mount the bucket on one machine and don't need NFS, just use https://github.com/s3fs-fuse/s3fs-fuse.

## Usage
1. Set up an S3 bucket, and get an AWS ID/KEY pair that has access to it.
2. Download [automated build](https://registry.hub.docker.com/u/ecardoso/s3fs-nfs/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull ecardoso/s3fs-nfs`

   (alternatively, you can build it yourself: `docker build -t="ecardoso/s3fs-nfs" github.com/eduardocardoso/s3fs-container`)
3. On Linux machines you need to load the NFS kernel modules. Add the following to the bottom of _/etc/modules_:

    ```
    nfs
    nfsd
    ```
boot2docker on OSX contains NFS modules already so you can skip this step.
4. `echo "options lockd nlm_udpport=32768 nlm_tcpport=32768" >/etc/modprobe.d/local.conf` (comments welcome on the equivalent for boot2docker)
5. Reboot to allow this changes to take effect 
6. Run an instance of this container:

    ```
    docker run -d --cap-add SYS_ADMIN -e AWS_ID=<AWS-id> -e AWS_KEY=<AWS-key> -e BUCKET=<bucket-name> -p 111:111 -p 111:111/udp -p 2049:2049 -p 2049:2049/udp -p 32765-32768:32765-32768 -p 32765-32768/32765-32768/udp --name=s3fs ecardoso/s3fs-nfs
    ```
    _\<bucket-name\>_ in this case is the name you chose; you don't need the full AWS URI. This command returns an container ID.
7. Check the logs of the newly launched instance to confirm that the container has started OK:

    ```
    docker logs <container-ID>
    ```
8. Mount the share on another computer:

    ```
    mount <docker-host>:/s3bucket /mnt/s3bucket -o soft
    ```
Some notes for further use:
* _/mnt/s3bucket_ needs to exist
* This will only work for root; if you want multiple users look into all_squash and modify this container accordingly
* To give users the right to mount things on the client define the mount in _/etc/exports_ and add the _users_ option
* If you want to tune S3FS you can pass the additional environment variable S3FS_OPTS in the same way BUCKET is passed.

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
