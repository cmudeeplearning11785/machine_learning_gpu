FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

ENV CUDA_HOME /usr/local/cuda

# Misc packages
RUN apt-get update
RUN apt-get install -y wget vim nano apt-utils
RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         vim \
         ca-certificates \
         libjpeg-dev \
         libpng-dev
RUN apt-get install -y python3 python3-dev python3-pip
RUN apt-get install -y python3-tk
RUN apt-get install -y sudo
RUN pip3 install --upgrade pip
RUN pip3 install tqdm h5py lmdb pandas
RUN pip3 install cffi
RUN pip3 install networkx scipy
RUN pip3 install scikit-image
RUN pip3 install dill
RUN pip3 install python-Levenshtein

#-----------------------------------
# Pytorch
#-----------------------------------
RUN pip3 install http://download.pytorch.org/whl/cu90/torch-0.3.1-cp35-cp35m-linux_x86_64.whl 
RUN pip3 install torchvision
RUN pip3 install git+https://github.com/pytorch/tnt.git@master
RUN pip3 install git+https://github.com/inferno-pytorch/inferno --no-deps
RUN pip3 install --upgrade pip


#-----------------------------------
# Sphinx
#-----------------------------------
RUN mkdir -p /home/sphinx
WORKDIR /home/sphinx
# Download is currently broken
#RUN wget -O pocketsphinx-5prealpha.tar.gz https://sourceforge.net/projects/cmusphinx/files/pocketsphinx/5prealpha/pocketsphinx-5prealpha.tar.gz/download 
#RUN wget -O sphinxbase-5prealpha.tar.gz https://sourceforge.net/projects/cmusphinx/files/sphinxbase/5prealpha/sphinxbase-5prealpha.tar.gz/download 
#RUN tar xzf pocketsphinx-5prealpha.tar.gz
#RUN tar xzf sphinxbase-5prealpha.tar.gz
ADD pocketsphinx-5prealpha.tar.gz /home/sphinx
ADD sphinxbase-5prealpha.tar.gz /home/sphinx
RUN apt-get install -y autoconf libtool automake bison swig

WORKDIR /home/sphinx/sphinxbase-5prealpha
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install
RUN ldconfig

WORKDIR /home/sphinx/pocketsphinx-5prealpha
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install
RUN ldconfig

# Jupyter
RUN pip3 install jupyter matplotlib ipywidgets
RUN jupyter nbextension enable --py widgetsnbextension

# Pycharm
WORKDIR /home
RUN wget https://download-cf.jetbrains.com/python/pycharm-community-2017.3.4.tar.gz
RUN tar xzf pycharm-community-2017.3.4.tar.gz

#RUN apt-get install -y software-properties-common python-software-properties
#RUN sh -c 'echo "deb http://archive.getdeb.net/ubuntu yakkety-getdeb apps" >> /etc/apt/sources.list.d/getdeb.list'
#RUN wget -q -O - http://archive.getdeb.net/getdeb-archive.key | apt-key add -
#RUN apt-get update
#RUN apt-get install -y pycharm
#RUN add-apt-repository ppa:ubuntu-desktop/ubuntu-make
#RUN apt-get update
#RUN apt-get install -y ubuntu-make
#RUN umake ide pycharm
#RUN apt-get -y install snap snapd
#RUN service  snapd restart
#RUN snap install pycharm-community --classic

# Tensorflow
RUN pip3 install tensorflow-gpu

#-----------------------------------
# CTC
#-----------------------------------

RUN pip3 install --upgrade pip

# Decoder
WORKDIR /home/ctc
RUN git clone --recursive https://github.com/parlance/ctcdecode.git
WORKDIR /home/ctc/ctcdecode
RUN pip3 install wget
COPY boost_1_63_0.tar.gz /home/ctc/ctcdecode/third_party/
RUN pip3 install .

# Warp-CTC
RUN apt-get install -y cmake
RUN git clone https://github.com/torch/distro.git /home/torch --recursive
RUN cd /home/torch && bash install-deps
ENV TORCH_NVCC_FLAGS -D__CUDA_NO_HALF_OPERATORS__
RUN cd /home/torch && ./install.sh
RUN apt-get install -y git cmake tree htop bmon iotop
RUN pip3 install cython
RUN apt-get install -y libffi-dev
WORKDIR /home/ctc
RUN git clone https://github.com/bstriner/warp-ctc.git
WORKDIR /home/ctc/warp-ctc
RUN ldconfig
RUN bash -c -l "cd /home/ctc/warp-ctc && mkdir build && cd build && cmake .. && make && make install"
ENV WARP_CTC_PATH /home/ctc/warp-ctc/build
RUN ldconfig
RUN bash -c -l "cd /home/ctc/warp-ctc/pytorch_binding && python3 setup.py install"
#RUN bash -c -l "cd /home/ctc/warp-ctc/pytorch_binding && pip3 install --global-option=build_ext --global-option=-I/home/ctc/warp-ctc/include ."
#RUN cd pytorch_binding && python3 setup.py install
RUN ldconfig


#-----------------------------------
# Cleanup
#-----------------------------------

WORKDIR /workspace
