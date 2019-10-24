FROM kaldiasr/kaldi:latest
MAINTAINER mrlonely <1394018128@qq.com>

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    gstreamer1.0-plugins-good \
    gstreamer1.0-tools \
    gstreamer1.0-pulseaudio \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-ugly  \
    libatlas3-base \
    libgstreamer1.0-dev \
    libtool-bin \
    python-pip \
    python-yaml \
    python-simplejson \
    python-setuptools \
    python-gi \
    build-essential \
    python-dev \
    zlib1g-dev && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    pip install ws4py==0.3.2 && \
    pip install tornado==4.5.3 && \
    pip install futures && \
    ln -s -f bash /bin/sh

RUN rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN cd /opt && \
    wget http://www.digip.org/jansson/releases/jansson-2.7.tar.bz2 && \
    bunzip2 -c jansson-2.7.tar.bz2 | tar xf -  && \
    cd jansson-2.7 && \
    ./configure && make && make check &&  make install && \
    echo "/usr/local/lib" >> /etc/ld.so.conf.d/jansson.conf && ldconfig && \
    rm /opt/jansson-2.7.tar.bz2 && rm -rf /opt/jansson-2.7



RUN cd /opt/kaldi/tools && \
    ./install_portaudio.sh && \
    cd /opt/kaldi/src/online && make depend -j $(nproc) && make -j $(nproc) && \
    cd /opt/kaldi/src/gst-plugin && sed -i 's/-lmkl_p4n//g' Makefile && make depend -j $(nproc) && make -j $(nproc) && \
    cd /opt && \
    git clone https://github.com/alumae/gst-kaldi-nnet2-online.git && \
    cd /opt/gst-kaldi-nnet2-online/src && \
    sed -i '/KALDI_ROOT?=\/home\/tanel\/tools\/kaldi-trunk/c\KALDI_ROOT?=\/opt\/kaldi' Makefile && \
    make depend -j $(nproc) && make -j $(nproc) && \
    rm -rf /opt/gst-kaldi-nnet2-online/.git/ && \
    find /opt/gst-kaldi-nnet2-online/src/ -type f -not -name '*.so' -delete && \
    rm -rf /opt/kaldi/.git && \
    rm -rf /opt/kaldi/egs/ /opt/kaldi/windows/ /opt/kaldi/misc/ && \
    find /opt/kaldi/src/ -type f -not -name '*.so' -delete && \
    find /opt/kaldi/tools/ -type f \( -not -name '*.so' -and -not -name '*.so*' \) -delete && \
    cd /opt && git clone https://github.com/naxingyu/kaldi-gstreamer-server.git && \
    rm -rf /opt/kaldi-gstreamer-server/.git/ && \
    rm -rf /opt/kaldi-gstreamer-server/test/ && \
    mkdir -p /opt/models/chinese && cd /opt/models/chinese && \
    wget http://kaldi-asr.org/models/11/0011_multi_cn_chain_sp_online.tar.gz && \
    tar zxvf 0011_multi_cn_chain_sp_online.tar.gz && \
    rm 0011_multi_cn_chain_sp_online.tar.gz && \
    cp /opt/kaldi-gstreamer-server/sample_chinese_nnet3.yaml /opt/models && \
    find /opt/models/ -type f | xargs sed -i 's:test:/opt:g' && \
    cd /opt

COPY start.sh stop.sh /opt/

RUN chmod +x /opt/start.sh && \
    chmod +x /opt/stop.sh
