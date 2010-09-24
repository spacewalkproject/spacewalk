#!/bin/bash

langs=(
en_US
bn_IN
de
en_US
es
fr
gu
hi
it
ja
ko
pa
pt_BR
ru
ta
zh_CN
zh_TW
)

for lang in "${langs[@]}"
do
	./check_java.sh "$lang"
done
