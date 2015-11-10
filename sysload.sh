#!/bin/bash
# system load for logging purposes and performance graphs
# crysman (copyleft) 2015

# changelog:
#  1.2 used memory patched to display correct value
#  1.1 instead of free mem, used mem is being used
#  1.0 initial release

date=`date "+%Y-%m-%d %H:%M:%S"`
hostname=`hostname`

#loadavg values:
loadavg=`cat /proc/loadavg`

#number of CPU's:
cpuN=`grep "processor.*:" /proc/cpuinfo | wc -l`

#used memory (properly calculated with buffers and cache):
memStats=`grep -E "^MemTotal|^MemFree|^Buffers|^Cached" /proc/meminfo`
memTotal=`echo "$memStats" | grep "MemTotal" | grep -Eo "[[:digit:]]+"`
memFree=`echo "$memStats" | grep "MemFree" | grep -Eo "[[:digit:]]+"`
buffers=`echo "$memStats" | grep "Buffers" | grep -Eo "[[:digit:]]+"`
cached=`echo "$memStats" | grep "Cached" | grep -Eo "[[:digit:]]+"`
memAvailable=$(($memFree+$buffers+$cached))
memUsed=`awk -v ma="$memAvailable" -v mt="$memTotal" 'BEGIN {printf "%.2f",(mt-ma)*100/mt}'`
#        ^bash cannot calculate decimals, let's use awk:

#IO operations:
IOms=`grep -vE "([[:blank:]]0){4,}" /proc/diskstats | awk '{total+=$13} END {printf "%.0f",total}'`
#           ^                                     ^ summing-up the 13-th field (field 10 of iostats = # of milliseconds spent doing I/Os)
#           |                                     - [https://www.kernel.org/doc/Documentation/iostats.txt]
#           - ignore all lines with 4 or more consecutive zeroes

#echo -n "host:$hostname"
#echo ",date | loadavg | #CPUs | %memUsed | I/O total ms"
echo "$date | $loadavg | $cpuN | $memUsed | $IOms"
