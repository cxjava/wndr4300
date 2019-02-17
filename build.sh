#!/bin/bash

PROJECT_ID=10873030
RELEASE_NAME=v0.1-$(date +%Y%m%d_%H%M%S)

FILE1="lede-imagebuilder-ar71xx-nand.Linux-x86_64.tar.xz"
OUT_DIR="/opt/lede/bin/targets/ar71xx/nand/"

pwd

ls -al

wget https://github.com/lede-project/source/commit/b87b4734c6e56fa45ec612350e2aa480ed2d8dd6.patch
sed -i "s/hack-4.4/patches-4.4/g" b87b4734c6e56fa45ec612350e2aa480ed2d8dd6.patch
touch target/linux/generic/config-4.9
patch -p1 < b87b4734c6e56fa45ec612350e2aa480ed2d8dd6.patch

sed -i  s/'23552k(ubi),25600k@0x6c0000(firmware)'/'120832k(ubi),122880k@0x6c0000(firmware)'/ target/linux/ar71xx/image/legacy.mk

ls -al
#wget -O /opt/lede/.config "https://github.com/cxjava/j2ee/releases/download/v0.0.1/config" 
make defconfig
ls -al

make -j1

du -h ${OUT_DIR}
pwd
ls -al
cd ..
pwd
tar -zcvf - lede | split -b 1500m -a 1 - lede.tar.gz.
# cat lede.tar.gz.* | tar xzvf -
ls -al

if [ $? -eq 0 ]; then

	echo "Begin upload the release: $RELEASE_NAME"
    
    github-release release \
		--user cxjava \
		--repo j2ee \
		--tag $RELEASE_NAME \
		--name $RELEASE_NAME \
		--description "wndr4300 image builder"
		
	github-release upload \
		--user cxjava \
		--repo j2ee \
		--tag $RELEASE_NAME \
		--name $FILE1 \
		--file /opt/lede/bin/targets/ar71xx/nand/lede-imagebuilder-ar71xx-nand.Linux-x86_64.tar.xz

	github-release upload \
		--user cxjava \
		--repo j2ee \
		--tag $RELEASE_NAME \
		--name lede.tar.gz.a \
		--file /opt/lede.tar.gz.a

	github-release upload \
		--user cxjava \
		--repo j2ee \
		--tag $RELEASE_NAME \
		--name lede.tar.gz.b \
		--file /opt/lede.tar.gz.b
					
    echo "===successfully!"
else
	echo "Build has been failed"
	exit 2
fi
