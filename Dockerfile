FROM nvidia/cuda:11.3.1-devel-ubuntu20.04
# # updating the CUDA Linux GPG Repository Key
COPY ./cuda-keyring_1.0-1_all.deb cuda-keyring_1.0-1_all.deb
# RUN rm /etc/apt/sources.list.d/cuda.list && rm /etc/apt/sources.list.d/nvidia-ml.list && dpkg -i cuda-keyring_1.0-1_all.deb
RUN rm /etc/apt/sources.list.d/cuda.list && dpkg -i cuda-keyring_1.0-1_all.deb

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
    python3-pip \
    python3-setuptools \
    libopenblas-dev \
    && apt-get -y clean all \
    && rm -rf /var/lib/apt/lists/*

# ======== Install Conda =======
# ENV CONDA_DIR /opt/conda
# RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
#     /bin/bash ~/miniconda.sh -b -p /opt/conda
# # Put conda in path so we can use conda activate
# ENV PATH=$CONDA_DIR/bin:$PATH
# # RUN /bin/bash -c "conda init bash"

# ===== Install further dependencies ========
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y ffmpeg \
    libsm6 \
    libxext6 \
    libopenexr-dev \ 
    openexr \
    && apt-get -y clean all \
    && rm -rf /var/lib/apt/lists/*

# # Install python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install -r requirements.txt
RUN pip install torch==1.10.0+cu113 torchvision==0.11.0+cu113 torchaudio==0.10.0 -f https://download.pytorch.org/whl/torch_stable.html


# # ======== Create conda environment ========
# COPY panoptic-reconstruction /usr/src/app/panoptic-reconstruction/
# WORKDIR /usr/src/app/panoptic-reconstruction

# RUN /bin/bash -c "conda env create --file environment.yaml"
# SHELL ["conda", "run", "-n", "panoptic", "/bin/bash", "-c"]

# RUN conda install ipython pip
# RUN pip install ninja yacs cython matplotlib tqdm opencv-python


# =========== Install maskrcnn-benchmark ===============
ENV INSTALL_DIR=/usr/src/app
ENV MAX_JOBS=8
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

# Install library
# WORKDIR /usr/src/app/panoptic-reconstruction
# RUN /bin/bash -c "cd lib/csrc/; python setup.py install"



ENV PYTHONPATH=/usr/src/app/panoptic-reconstruction
# ENTRYPOINT "cd /usr/src/app/panoptic-reconstruction/lib/csrc; python3 setup.py install" && /bin/bash

# python3 tools/test_net_single_image.py -i data/front3d-sample/rgb_0007.png -o output/test.png
# RUN conda init bash

# # Install python dependencies
# COPY requirements.txt .
# RUN pip install --upgrade pip \
#     && pip install -r requirements.txt

# # =========== Install Pytorch 1.10  ==============
# RUN pip install torch==1.10.0+cu113 torchvision==0.11.0+cu113 torchaudio==0.10.0 -f https://download.pytorch.org/whl/torch_stable.html
# # pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113



# # =========== Install maskrcnn-benchmark ===============
# WORKDIR /usr/src/app
# ENV INSTALL_DIR=/usr/src/app
# ENV MAX_JOBS=8
# ENV CUDA_HOME=/usr/local/cuda-11.3
# ENV CXX=c++
# ENV PATH=$PATH:/usr/local/cuda-11.3/bin
# WORKDIR $INSTALL_DIR

# RUN /bin/bash -c "git clone https://github.com/cocodataset/cocoapi.git; cd cocoapi/PythonAPI; python3 setup.py build_ext install"
# RUN /bin/bash -c "cd ${INSTALL_DIR}; git clone https://github.com/mcordts/cityscapesScripts.git; cd cityscapesScripts/; python3 setup.py build_ext install"
# RUN /bin/bash -c "cd ${INSTALL_DIR}; git clone https://github.com/NVIDIA/apex.git; cd apex; python3 setup.py install --cuda_ext --cpp_ext"
# RUN /bin/bash -c "cd ${INSTALL_DIR}; git clone https://github.com/facebookresearch/maskrcnn-benchmark.git; cd maskrcnn-benchmark; cuda_dir='maskrcnn_benchmark/csrc/cuda'; perl -i -pe 's/AT_CHECK/TORCH_CHECK/' maskrcnn_benchmark/csrc/cuda/deform_pool_cuda.cu maskrcnn_benchmark/csrc/cuda/deform_conv_cuda.cu; python3 setup.py build develop"

# # ## Install MinkowskiEngine
# # # ENV CXX=c++
# # # ENV CUDA_HOME=/usr/local/cuda-11.0
# RUN /bin/bash -c "git clone https://github.com/xheon/MinkowskiEngine.git; cd MinkowskiEngine; python3 setup.py install --blas=openblas --force_cuda"



# ENV PYTHONPATH=/usr/src/app/panoptic-reconstruction
# WORKDIR /usr/src/app/