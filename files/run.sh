#!/bin/bash
AWS_ID=${AWS_ID}
AWS_KEY=${AWS_KEY}
BUCKET=${BUCKET}
S3FS_OPTS=${S3FS_OPTS}

/etc/init.d/nfs-kernel-server stop

echo "${AWS_ID}:${AWS_KEY}" > /etc/passwd-s3fs
chmod 0600 /etc/passwd-s3fs

s3fs ${BUCKET} /s3bucket ${S3FS_OPTS}

rpcbind
/etc/init.d/nfs-kernel-server start

sleep infinity
