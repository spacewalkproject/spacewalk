#!/bin/bash


if [ -z $1 ]
then 
	echo "usage ./create-dump-dir.sh URL_TO_ISOs"
	echo ""
	echo "This utility is used to pull down a directory full of channel dump isos, mount them, and extract them into a directory. When finished, a directory 'dump' will be created in the current working directory that contains the full channel dump tree."
	exit 0
fi


ISOLIST="isolist.txt"

URL=$1

echo "Downloading from $URL"
echo "Fetching iso list"

wget -o /dev/null $URL -O - | awk -F '"' '/iso/ {print $6}' > $ISOLIST
NUM=`cat $ISOLIST | wc -l`
echo "Found $NUM disc images"

if [ $NUM -eq 0 ]
  then
	exit 1
fi


rm -rf ./dump/ 

mkdir ./dump/
mkdir ./mount/ &> /dev/null
umount ./mount &> /dev/null

echo "Processing isos..."
let TMP=1

for i in `cat $ISOLIST`; do
	echo -n "$TMP / $NUM  "
	rm -rf $i &> /dev/null
	echo -n "Downloading...."
	wget -o /dev/null $URL/$i
	mount -o loop $i ./mount
	echo -n "Copying......"
	cp -rf ./mount/* ./dump/
	umount ./mount
	rm -rf $i
	echo "..Done"
	let TMP=$TMP+1
done

echo "DONE"

