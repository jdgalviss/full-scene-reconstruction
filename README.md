# WIP: Currently cleaning up the code

# full-scene-reconstruction
Full Scene Reconstruction of a 3D scene (geometry, instance ids, semantic labels, and color) from an RGB Image

![05](https://user-images.githubusercontent.com/18732666/178697103-488e2650-ba0e-4bcd-bd9d-c6bf2d14807f.gif)
![06](https://user-images.githubusercontent.com/18732666/178697114-2201f081-875e-4033-9a0d-4e44dcdba55e.gif)

## Install
1. Install Docker following the instructions on the [link](https://docs.docker.com/engine/install/ubuntu/) and [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) (for gpu support).

3. Clone this repo and its submodules 
    ```bash
    git clone --recursive -j8 git@github.com:jdgalviss/full-scene-reconstruction.git
    cd full-scene-reconstruction
    ```
4. Build Docker Container
    ```bash
    docker build . -t scene_reconstruction
    ```
## Run Inference
1. Run Docker container
    ```bash
    source run_docker.sh 
    ```

2. [Download pretrained model](http://kaldir.vc.in.tum.de/panoptic_reconstruction/panoptic-front3d.pth) and put it in the data folder

3. Run inference inside docker container

    ```bash
    python tools/test_net_single_image.py -i data/front3d-sample/rgb_0007.png -o output/
    ```

4. Train
    Inside docker:
    ```bash
    python tools/train_full_reconstruction.py --config configs/front3d_train_3d.yaml --output-path output/
    ```
5. Evaluation
    Inside docker:
    ```bash
    python tools/evaluate_net.py --config configs/front3d_evaluate.yaml --output output/
    ```

6. Run jupyter lab inside Docker
    ```bash
    jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --no-browser
    ```
