#!/bin/bash

username=$1

sudo -E kill -9 $(ps aux | grep '[r]aid' | awk '{print $2}')
sudo -E kill -9 $(ps aux | grep '[n]vmf_tgt' | awk '{print $2}')
cd /users/$username/draid-spdk
sudo -E ./scripts/setup.sh reset
