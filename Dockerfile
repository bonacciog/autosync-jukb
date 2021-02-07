# Musixmatch Intelligence SDK for Docker
# @author Loreto Parisi loreto@musixmatch.com
# @2016-2019 Musixmatch Spa

FROM debian:10
LABEL maintainer="rick@scriptix.io"

WORKDIR /home/jovyan/

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
        ca-certificates \
        gfortran \
        patch \
        ffmpeg \
    vim && \
    rm -rf /var/lib/apt/lists/*

RUN apt update && apt install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get install python-pip python3-pip

RUN python3 -m pip install --upgrade pip
RUN ln -s /usr/bin/python3 /usr/bin/python

RUN git clone --depth 1 https://github.com/kaldi-asr/kaldi.git /opt/kaldi #EOL
RUN    cd /opt/kaldi/tools && \
       ./extras/install_mkl.sh && \
       make -j $(nproc) && \
       cd /opt/kaldi/src && \
       ./configure --shared && \
       make depend -j $(nproc) && \
       make -j $(nproc) && \
       find /opt/kaldi -type f \( -name "*.o" -o -name "*.la" -o -name "*.a" \) -exec rm {} \; && \
       find /opt/intel -type f -name "*.a" -exec rm {} \; && \
       find /opt/intel -type f -regex '.*\(_mc.?\|_mic\|_thread\|_ilp64\)\.so' -exec rm {} \; && \
       rm -rf /opt/kaldi/.git


# Kubeflow config
# jupyter
RUN pip install jupyterlab

ENV NB_PREFIX /

CMD ["sh","-c", "jupyter notebook --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX}"]