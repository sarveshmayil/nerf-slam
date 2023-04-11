ARG BASE_IMG=nvidia/cuda:11.3.0-cudnn8-devel-ubuntu20.04

FROM ${BASE_IMG}

RUN apt-get -y update \
    && apt-get -y install \
      python3-pip \
      sudo \
      vim \
      wget \
      curl \
      software-properties-common \
      doxygen \
      git \
    && rm -rf /var/lib/apt/lists/*

RUN 
