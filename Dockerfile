FROM debian:10

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR app

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
        dos2unix \
        ffmpeg \
        jq \
	    vim && \
    rm -rf /var/lib/apt/lists/*

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

RUN apt-get install -y python3 python-dev python3-dev \
     build-essential libssl-dev libffi-dev \
     libxml2-dev libxslt1-dev zlib1g-dev \
     python-pip python3.7-dev python3-pip

RUN python3.7 -m pip install --upgrade pip
RUN ln -sfn /usr/bin/python3.7 /usr/bin/python3
RUN ln -sfn /usr/bin/python3.7 /usr/bin/python

WORKDIR /home/jovyan/

RUN python3 -m pip install jupyterlab

ENV NB_PREFIX /

CMD ["sh","-c", "jupyter notebook --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX}"]
