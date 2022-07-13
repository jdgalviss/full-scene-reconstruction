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
    -v `pwd`/spsg:/usr/src/app/spsg \
    -v `pwd`/spsg:/usr/src/app/spsg \
    -v /home/zuzka/front3d-full/:/usr/src/app/panoptic-reconstruction/data/front3d \
    --shm-size 24G \
    scene_reconstruction "$@"

# python test_scene_as_chunks.py --gpu 0 --input_data_path ../data/mp_sdf_2cm_input --target_data_path ../data/mp_sdf_2cm_target --test_file_list ../filelists/mp-rooms_test-jd.txt --model_path spsg.pth --output ./output --max_to_vis 20