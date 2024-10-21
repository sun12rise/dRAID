#!/bin/bash

# This is a script for CentOS 8

cd ~

# basic configuration for SPDK
sudo sh -c "echo -e \"*        hard    memlock         unlimited\n*        soft    memlock         unlimited\" >> /etc/security/limits.conf"
sudo ifconfig eno34 mtu 4200
sudo sysctl -w vm.nr_hugepages=32768

# clone customized version of SPDK and FIO for dRAID
git clone https://github.com/kyleshu/draid-spdk.git
cd draid-spdk
git submodule update --init
sudo apt-get update
ruby -v
# 安装 rbenv（如果尚未安装）
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-installer | bash

# 添加 rbenv 到 PATH
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# 安装 Ruby 3.0.0
rbenv install 3.0.0
rbenv global 3.0.0
#Ruby 版本升级完成后，安装 Bundler：
gem install bundler

sudo scripts/pkgdep.sh --all
cd ..
git clone https://github.com/axboe/fio
cd fio
make
sudo make install
sudo ldconfig
cd ..
cd draid-spdk

sudo apt update
sudo apt install nasm

sudo apt remove nasm -y

#下载 NASM 新版本源代码：
cd /tmp
wget https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.gz
tar -xzf nasm-2.15.05.tar.gz
cd nasm-2.15.05
./autogen.sh
./configure --prefix=/usr/local
make
sudo make install
nasm -v
which nasm
echo $PATH
hash -r
nasm -v

#输出 NASM version 2.15.05 compiled on Oct 17 2024
#返回spdk

cd  ~/draid-spdk
./configure --with-rdma --with-fio=$HOME/fio --with-isal --with-raid5 --disable-unit-tests
make
cd ..

# clone the original SPDK as baseline
git clone https://github.com/kyleshu/spdk.git
cd spdk
git submodule update --init
./configure --with-rdma --with-fio=$HOME/fio --with-isal --with-raid5 --disable-unit-tests
make
cd ..

# clone customized version of rocksdb for testing
git clone https://github.com/kyleshu/rocksdb.git


# 要添加的内容
# 添加内容到 ~/.bashrc
echo "export PKG_CONFIG_PATH=~/draid-spdk/build/lib/pkgconfig:\$PKG_CONFIG_PATH" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=~/draid-spdk/build/lib:\$LD_LIBRARY_PATH" >> ~/.bashrc
source ~/.bashrc




