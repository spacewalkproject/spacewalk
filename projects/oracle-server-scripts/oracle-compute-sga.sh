#!/bin/sh

# system memory and cpus
cpus=$(grep ^processor /proc/cpuinfo | wc -l)
total=$(free -m -o | awk '/Mem:/ {print $2}')

# all sizes are in MB
sgamin=256
sgamin_for_cpus=$((10*$cpus))
if [ $sgamin -lt $sgamin_for_cpus ] ; then
        sgamin=$sgamin_for_cpus
fi
sgamax=2048
if [ "$(uname -i)" = "i386" ] ; then
        sgamax=1500
fi
pgamin=128
pgamax=1024

oracle_mem=$(($total * 40/100 - 64))

sga_target=$(($oracle_mem * 75/100))
pga_target=$(($oracle_mem * 25/100))

if [ $sga_target -lt $sgamin ] ; then
        sga_target=$sgamin
fi
if [ $sga_target -gt $sgamax ] ; then
        sga_target=$sgamax
fi

if [ $pga_target -lt $pgamin ] ; then
        pga_target=$pgamin
fi
if [ $pga_target -gt $pgamax ] ; then
        pga_target=$pgamax
fi

echo sga_target=$sga_target
echo pga_aggregate_target=$pga_target
