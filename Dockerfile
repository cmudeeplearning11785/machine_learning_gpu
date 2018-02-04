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

# Jupyter
RUN pip install jupyter matplotlib ipywidgets
RUN jupyter nbextension enable --py widgetsnbextension

#-----------------------------------
# Cleanup
#-----------------------------------

WORKDIR /home
