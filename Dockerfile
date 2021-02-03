# Musixmatch Intelligence SDK for Docker
# @author Loreto Parisi loreto@musixmatch.com
# @2016-2019 Musixmatch Spa

FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04

MAINTAINER Simone Francia simone.francia@musixmatch.com

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /home/jovyan

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        g++ \
        make \
        automake \
        autoconf \
        bzip2 \
        unzip \
        wget \
        sox \
        libtool \
        git \
        subversion \
        python2.7 \
        python3 \
        zlib1g-dev \
        gfortran \
        ca-certificates \
        patch \
        ffmpeg \
	vim && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python2.7 /usr/bin/python

RUN git clone --depth 1 https://github.com/kaldi-asr/kaldi.git /opt/kaldi && \
    cd /opt/kaldi/tools && \
    ./extras/install_mkl.sh && \
    make -j $(nproc) && \
    cd /opt/kaldi/src && \
    ./configure --shared --use-cuda && \
    make depend -j $(nproc) && \
    make -j $(nproc) && \
    find /opt/kaldi  -type f \( -name "*.o" -o -name "*.la" -o -name "*.a" \) -exec rm {} \; && \
    find /opt/intel -type f -name "*.a" -exec rm {} \; && \
    find /opt/intel -type f -regex '.*\(_mc.?\|_mic\|_thread\|_ilp64\)\.so' -exec rm {} \; && \
    rm -rf /opt/kaldi/.git


RUN apt update && apt install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt update && apt install python3.7 -y

RUN apt-get install -y python3 python-dev python3-dev \
     build-essential libssl-dev libffi-dev \
     libxml2-dev libxslt1-dev zlib1g-dev \
     python-pip python3.7-dev python3-pip

RUN python3.7 -m pip install --upgrade pip
RUN ln -sfn /usr/bin/python3.7 /usr/bin/python3

 #COPY src/workers/autosync_acoustic/requirements.txt /tmp/requirements.txt
 #RUN xargs -L 1 pip3 install < /tmp/requirements.txt && rm /tmp/requirements.txt

 #COPY lib/audio/acoustic_sync/src acoustic_sync_lib
 #COPY lib/deeplearning/dataset dataset
 #COPY lib/deeplearning/util_deeplearning util_deeplearning
 #COPY lib/deeplearning/queue_amq queue_amq

 #COPY src/workers/autosync_acoustic* .

# CMD ["python", "worker.py"]

# Kubeflow config
# jupyter
RUN pip install jupyterlab

ENV NB_PREFIX /

CMD ["sh","-c", "jupyter notebook --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX}"]