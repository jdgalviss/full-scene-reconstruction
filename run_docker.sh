#!/bin/bash
sudo xhost +si:localuser:root
XSOCK=/tmp/.X11-unix

docker run -it --rm  \
    --net=host  \
    --privileged \
    --runtime=nvidia \
    -e DISPLAY=$DISPLAY \
    -v $XSOCK:$XSOCK \
    -v $HOME/.Xauthority:/root/.Xauthority \
    -v `pwd`/panoptic-reconstruction:/usr/src/app/panoptic-reconstruction \
    -v `pwd`/differential_rendering:/usr/src/app/differential_rendering \
    --shm-size 8G \
    scene_reconstruction "$@"

