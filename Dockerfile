FROM ubuntu
#---INSTALL EXIM---INSTALL EXIM---INSTALL EXIM---INSTALL EXIM
# get tools and dependencies for building
RUN apt-get update && \
apt-get upgrade && \
apt-get install -y \
libssl-dev \
curl \
gcc make \
pkg-config \
procps libpcre3-dev libdb-dev libxt-dev libxaw7-dev
# create exim user
RUN useradd exim-demo
# get sources
WORKDIR /opt
RUN curl 'https://codeload.github.com/Exim/exim/tar.gz/refs/tags/exim-4.94' --output exim-4.94.tar.gz && \
tar xf exim-4.94.tar.gz --directory=. && \
rm exim-4.94.tar.gz && \
mv exim-exim-4.94 exim-4.94
WORKDIR /opt/exim-4.94/src
# copy config files
RUN touch /etc/aliases
COPY exim-files.d/Makefile Local/Makefile
COPY exim-files.d/Makefile-Linux Local/Makefile-Linux
COPY exim-files.d/configure /usr/exim/configure
RUN make install

#---INSTALL TOOLS---INSTALL TOOLS---INSTALL TOOLS---INSTALL TOOLS---INSTALL TOOLS
# get required packages
RUN apt-get install -y \
vim gdb python3-pip git zsh 
# home directory
WORKDIR /root/
# gdb extensions 
RUN git clone https://github.com/pwndbg/pwndbg.git && \
./pwndbg/setup.sh
# setup dotfiles and configure ssh
RUN git clone https://github.com/vobst/dotfiles.git && \
./dotfiles/scripts/install.sh && \
echo 'source /root/pwndbg/gdbinit.py' >> .gdbinit_local
# frida
RUN pip install frida-tools

#---START EXIM---START EXIM---START EXIM---START EXIM---START EXIM---START EXIM
CMD ["/usr/exim/bin/exim", "-bd", "-q30m"]
