#!/bin/bash

sudo apt install autoconf libtool libdaemon-dev libasound2-dev libpopt-dev libconfig-dev libssl-dev libavahi-client-dev git
cd
git clone https://github.com/mikebrady/shairport-sync.git
cd shairport-sync/
autoreconf -i -f
./configure --with-alsa --with-avahi --with-ssl=openssl --with-systemd --with-metadata
make
sudo make install
sudo systemctl enable shairport-sync
sudo systemctl start shairport-sync

