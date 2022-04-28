FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
#---INSTALL EXIM---INSTALL EXIM---INSTALL EXIM---INSTALL EXIM
# get tools and dependencies for building
RUN apt-get update && \
apt-get install -y --no-install-suggests --no-install-recommends \
ca-certificates \
git \
gcc \
make \
pkg-config \
procps \
libssl-dev \
libpcre3-dev \
libdb-dev \
libxt-dev \
libxaw7-dev && \
rm -rf /var/lib/apt/lists/*
# create exim user
RUN useradd exim-demo
# get sources of last vuln version
WORKDIR /opt
RUN git clone -b exim-4.94+fixes --single-branch \
https://github.com/Exim/exim exim-4-94
WORKDIR /opt/exim-4-94
RUN git checkout 0aafa26a5d3d528e79476c91537c28936154fe04
WORKDIR /opt/exim-4-94/src
# copy config files
RUN ls && pwd && touch /etc/aliases
COPY exim-files.d/Makefile Local/Makefile
COPY exim-files.d/Makefile-Linux Local/Makefile-Linux
COPY exim-files.d/configure /usr/exim/configure
RUN make && make install && make clean

#---INSTALL TOOLS---INSTALL TOOLS---INSTALL TOOLS---INSTALL TOOLS
# get required packages
RUN apt-get update && \
apt-get install -y --no-install-suggests --no-install-recommends \
vim \
gdb \
python3-pip \
git \
zsh && \ 
rm -rf /var/lib/apt/lists/*
# home directory
WORKDIR /root/
# gdb extensions 
RUN git clone https://github.com/pwndbg/pwndbg.git
WORKDIR /root/pwndbg/
RUN ./setup.sh
# setup dotfiles and configure ssh
WORKDIR /root/
RUN git clone https://github.com/vobst/dotfiles.git && \
./dotfiles/scripts/install.sh && \
echo 'source /root/pwndbg/gdbinit.py' >> .gdbinit_local
# frida
RUN pip install frida-tools

#---START EXIM---START EXIM---START EXIM---START EXIM---START EXIM
CMD ["/usr/exim/bin/exim", "-bd", "-q30m"]
