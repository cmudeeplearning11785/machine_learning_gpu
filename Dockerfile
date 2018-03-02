FROM pytorch/pytorch

#-----------------------------------
# Pytorch
#-----------------------------------
RUN pip install tqdm h5py lmdb pandas
RUN pip install http://download.pytorch.org/whl/cu80/torch-0.3.0.post4-cp35-cp35m-linux_x86_64.whl
RUN pip install torchvision
RUN pip install inferno-pytorch
RUN pip install git+https://github.com/pytorch/tnt.git@master

RUN apt-get update
RUN apt-get install wget

#-----------------------------------
# Sphinx
#-----------------------------------
RUN mkdir -p /home/sphinx
WORKDIR /home/sphinx
RUN wget -O pocketsphinx-5prealpha.tar.gz https://sourceforge.net/projects/cmusphinx/files/pocketsphinx/5prealpha/pocketsphinx-5prealpha.tar.gz/download 
RUN wget -O sphinxbase-5prealpha.tar.gz https://sourceforge.net/projects/cmusphinx/files/sphinxbase/5prealpha/sphinxbase-5prealpha.tar.gz/download 

RUN tar xzf pocketsphinx-5prealpha.tar.gz
RUN tar xzf sphinxbase-5prealpha.tar.gz

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
RUN pip install jupyter matplotlib ipywidgets
RUN jupyter nbextension enable --py widgetsnbextension

# Pycharm

RUN apt-get update
RUN apt-get -y install apt-utils
RUN apt-get install -y software-properties-common python-software-properties
RUN sh -c 'echo "deb http://archive.getdeb.net/ubuntu yakkety-getdeb apps" >> /etc/apt/sources.list.d/getdeb.list'
RUN wget -q -O - http://archive.getdeb.net/getdeb-archive.key | apt-key add -
RUN apt-get update
RUN apt-get install -y pycharm
#RUN add-apt-repository ppa:ubuntu-desktop/ubuntu-make
#RUN apt-get update
#RUN apt-get install -y ubuntu-make
#RUN umake ide pycharm
#RUN apt-get -y install snap snapd
#RUN service  snapd restart
#RUN snap install pycharm-community --classic

RUN pip install git+https://github.com/inferno-pytorch/inferno --no-deps
#RUN apt-get install cuda-command-line-tools
RUN pip install tensorflow-gpu

#-----------------------------------
# CTC
#-----------------------------------

RUN apt-get install -y cmake
WORKDIR /home/ctc
RUN git clone https://github.com/SeanNaren/warp-ctc.git
WORKDIR /home/ctc/warp-ctc
RUN mkdir build && cd build && cmake .. && make && make install
RUN cd pytorch_binding && python3 setup.py install
RUN ldconfig

# Decoder
WORKDIR /home/ctc
RUN git clone --recursive https://github.com/parlance/ctcdecode.git
WORKDIR /home/ctc/ctcdecode
RUN pip install wget
COPY boost_1_63_0.tar.gz /home/ctc/ctcdecode/third_party/
RUN pip install .

#-----------------------------------
# Cleanup
#-----------------------------------

WORKDIR /home
