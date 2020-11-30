#!/bin/bash

sudo yum install -y epel-release
sudo yum localinstall -y --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
sudo yum install -y ffmpeg ffmpeg-devel
ffmpeg -version

