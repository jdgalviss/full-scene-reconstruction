FROM nvidia/cuda:11.3.1-devel-ubuntu20.04

# Install basic packages
ENV TZ=Europe/London
ENV DEBIAN_FRONTEND=noninteractive
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    wget \
    git \
    unzip \
    curl \
    nano \
    libopenexr-dev \
    openexr \
    ffmpeg \
    python3-pip \
    python3-setuptools \
    libopenblas-dev \
    && apt-get -y clean all \
    && rm -rf /var/lib/apt/lists/*

# # updating the CUDA Linux GPG Repository Key
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb
# RUN rm /etc/apt/sources.list.d/cuda.list && rm /etc/apt/sources.list.d/nvidia-ml.list && dpkg -i cuda-keyring_1.0-1_all.deb
RUN rm /etc/apt/sources.list.d/cuda.list && dpkg -i cuda-keyring_1.0-1_all.deb

# # Install python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir torch==1.10.0+cu113 torchvision==0.11.0+cu113 torchaudio==0.10.0 -f https://download.pytorch.org/whl/torch_stable.html

# =========== Install maskrcnn-benchmark ===============
ENV INSTALL_DIR=/usr/src/app
ENV MAX_JOBS=4
ENV CUDA_HOME=/usr/local/cuda-11.3
ENV CXX=c++
ENV PATH=$PATH:/usr/local/cuda-11.3/bin
WORKDIR $INSTALL_DIR

RUN /bin/bash -c "git clone https://github.com/cocodataset/cocoapi.git; cd cocoapi/PythonAPI; python3 setup.py build_ext install"
RUN /bin/bash -c "cd ${INSTALL_DIR}; git clone https://github.com/mcordts/cityscapesScripts.git; cd cityscapesScripts/; python3 setup.py build_ext install"
RUN /bin/bash -c "cd ${INSTALL_DIR}; git clone https://github.com/NVIDIA/apex.git; cd apex; python3 setup.py install --cuda_ext --cpp_ext"
RUN /bin/bash -c "cd ${INSTALL_DIR}; git clone https://github.com/facebookresearch/maskrcnn-benchmark.git; cd maskrcnn-benchmark; cuda_dir='maskrcnn_benchmark/csrc/cuda'; perl -i -pe 's/AT_CHECK/TORCH_CHECK/' maskrcnn_benchmark/csrc/cuda/deform_pool_cuda.cu maskrcnn_benchmark/csrc/cuda/deform_conv_cuda.cu; python3 setup.py build develop"

# ## Install MinkowskiEngine
ENV MAX_JOBS=4
RUN /bin/bash -c "git clone https://github.com/xheon/MinkowskiEngine.git; cd MinkowskiEngine; python3 setup.py install --blas=openblas --force_cuda"

# RUN pip install jupyterlab
### K3D
# RUN pip install k3d
RUN /bin/bash -c "jupyter nbextension install --py --user k3d; jupyter nbextension enable --py --user k3d"

RUN pip install "git+https://github.com/facebookresearch/pytorch3d.git"
RUN pip install plotly
RUN pip install imageio scikit-image
RUN pip install git+https://github.com/tatsy/torchmcubes.git

ENV PYTHONPATH=/usr/src/app/panoptic-reconstruction:/usr/src/app/spsg/torch
RUN pip install "git+https://github.com/facebookresearch/pytorch3d.git"
RUN pip install plotly
COPY .bashrc /root/.bashrc
WORKDIR /usr/src/app/panoptic-reconstruction
