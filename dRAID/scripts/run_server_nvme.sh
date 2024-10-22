#!/bin/bash

username=$1
raid_option=$2
i=$3
network=$4
chunk=$5
raid_size=$6
num_qp=$7

sudo -E kill -9 $(ps aux | grep '[i]p_addrs_' | awk '{print $2}')
sudo -E kill -9 $(ps aux | grep '[n]vmf_tgt' | awk '{print $2}')

sudo -E rm /dev/shm/*

cd /users/$username/draid-spdk
sudo -E ./scripts/setup.sh reset
sudo -E HUGEMEM=90000 PCI_ALLOWED="0000:c6:00.0" ./scripts/setup.sh

cd /users/$username/dRAID/dRAID/server
sudo -E rm nohup.out
sudo -u $username -E make clean
sudo -u $username -E make $raid_option

sudo sh -c -E  "nohup ./$raid_option -P $i -b Nvme0n1 -c nvme0.json -m 0x10000 -a /users/$username/artifacts/ip_addrs_$network.txt -S $chunk -N $raid_size -E $num_qp > /dev/null 2>&1 &"
