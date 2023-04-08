# ARG BASE_IMAGE=nvcr.io/nvidia/pytorch:21.10-py3
ARG BASE_IMAGE=11.3.0-base-ubuntu20.04:latest

FROM ${BASE_IMAGE}

ARG USER_NAME=walter
ARG USER_ID=1000

# Prevent anything requiring user input
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=linux

# ENV TZ=America
# RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone



RUN echo cmake --version

RUN apt remove --purge --auto-remove cmake
RUN apt-get -y update && \
    apt install -y software-properties-common lsb-release && \
    apt clean all

RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
RUN sudo apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main"

RUN apt-get -y update && \ 
    apt-get -y install cmake && \
    rm -rf /var/lib/apt/lists/*

ENV CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-11.3

# Clone NeRF-SLAM
WORKDIR /home/${USER_NAME}
RUN git clone https://github.com/ToniRV/NeRF-SLAM.git --recurse-submodules
WORKDIR /home/${USER_NAME}/NeRF-SLAM
RUN git submodule update --init --recursive


# Install CUDA 11.3
RUN pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 --extra-index-url https://download.pytorch.org/whl/cu113
RUN pip install -r requirements.txt
RUN pip install -r ./thirdparty/gtsam/python/requirements.txt

# Install Instant-NGP dependeicies
RUN apt-get -y update
RUN apt-get -y install libx11-dev libxrandr-dev
RUN apt-get -y install libxinerama-dev
RUN apt-get -y install libxcursor-dev
RUN apt-get -y install libxi-dev
RUN apt-get -y install libglew-dev
RUN apt-get -y install libboost-all-dev
RUN rm -rf /var/lib/apt/lists/*

# Install Instant NGP
RUN cmake ./thirdparty/instant-ngp -B build_ngp 
RUN cmake --build build_ngp --config RelWithDebInfo -j 1

# Install GTSAM
RUN git clone https://github.com/borglab/gtsam.git
RUN rm -r thirdparty/gtsam
RUN mv -v gtsam thirdparty/
RUN cmake ./thirdparty/gtsam -DGTSAM_BUILD_PYTHON=1 -B build_gtsam 
RUN cmake --build build_gtsam --config RelWithDebInfo -j 4
RUN cd build_gtsam && make python-install

# Install NeRF-SLAM
RUN python3 setup.py install

RUN useradd -m -l -u ${USER_ID} -s /bin/bash ${USER_NAME} \
    && usermod -aG video ${USER_NAME}

# Give them passwordless sudo
RUN echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch to user to run user-space commands
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}