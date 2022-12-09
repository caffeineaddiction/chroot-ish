#!/bin/bash
SB_PATH="/opt/_data/sandbox"
SB_USER="$(whoami)"
SB_NAME="sandbox-$SB_USER"
SB_HOME="/home/$SB_USER"
SB_CMD="bash"

SB_TYPE="-i"
if [ "$SSH_ORIGINAL_COMMAND" = "" ]
then
  SB_TYPE="-it"
else
  SB_CMD="$SSH_ORIGINAL_COMMAND"
fi


podman container exists $SB_NAME
if [ $? -gt 0 ]
then
  #RUN
  podman run --rm $SB_TYPE \
    --userns keep-id  \
    --hostname sandbox \
    --name $SB_NAME \
    -v $SB_PATH$SB_HOME:$SB_HOME \
    --workdir $SB_HOME \
    localhost/tshell  $SB_CMD
else
  #Exec
  podman exec $SB_TYPE $SB_NAME $SB_CMD
fi
