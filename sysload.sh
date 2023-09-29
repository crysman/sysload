#!/bin/bash
# system load for logging purposes and performance graphs
# crysman (copyleft) 2015-2023

# changelog:
# 2022-09-29  memUsed2 added (using free), columns reordered to $date | $loadavg | $cpuN | $memUsed | $memUsed2 | $IOms | $uptime
# 2022-08-19  output sanitized (head), slight optimalization, uptime added as 6th column
# 1.2a        date format changed - there is a comma now instead of space
# 1.2         used memory patched to display correct value
# 1.1         instead of free mem, used mem is being used
# 1.0         initial release

date=`date "+%Y-%m-%d,%H:%M:%S"`
hostname=`hostname`

#loadavg values:
loadavg=`head -1 /proc/loadavg`

#number of CPU's:
cpuN=`grep "processor.*:" /proc/cpuinfo | wc -l`

#used memory (properly calculated with buffers and cache):
#more info e.g. here http://www.linuxatemyram.com/
memStats=`grep -E "^MemTotal:|^MemFree:|^Buffers:|^Cached:" /proc/meminfo`
memTotal=`echo "$memStats" | awk '/MemTotal:/{print $2}'`
 memFree=`echo "$memStats" | awk '/MemFree:/{print $2}'`
 buffers=`echo "$memStats" | awk '/Buffers:/{print $2}'`
  cached=`echo "$memStats" | awk '/Cached:/{print $2}'`
memAvailable=$(($memFree+$buffers+$cached))
memUsedp=`awk -v ma="$memAvailable" -v mt="$memTotal" 'BEGIN {printf "%.2f",(mt-ma)*100/mt}'`
#        ^bash cannot calculate decimals, let's use awk:

memStats2=`free -b  | grep "^Mem:"`
memTotal2=`echo "$memStats2" | awk '{print $2}'`
 memAvailable2=`echo "$memStats2" | awk '{print $7}'`
 memUsed2=$(($memTotal2-$memAvailable2))
memUsed2s=`echo "$memUsed2/$memTotal2"`
memUsed2p=`awk -v ma="$memAvailable2" -v mt="$memTotal2" 'BEGIN {printf "%.2f",(mt-ma)*100/mt}'`
#        ^bash cannot calculate decimals, let's use awk:

#IO operations:
IOms=`grep -vE "([[:blank:]]0){4,}" /proc/diskstats | awk '{total+=$13} END {printf "%.0f",total}'`
#           ^                                     ^ summing-up the 13-th field (field 10 of iostats = # of milliseconds spent doing I/Os)
#           |                                     - [https://www.kernel.org/doc/Documentation/iostats.txt]
#           - ignore all lines with 4 or more consecutive zeroes

#uptime:
#The first value represents the total number of seconds the system has been up. The second value is the sum of how much time each core has
#spent idle, in seconds. Consequently, the second value may be greater than the overall system uptime on systems with multiple cores.
uptime=`head -1 /proc/uptime`

#echo -n "host:$hostname"
#echo ",date |  loadavg | #CPUs | %memUsed  | memUsed/memTotal (%)    | I/O total ms | uptime"
echo "$date | $loadavg | $cpuN | $memUsedp | $memUsed2s ($memUsed2p) | $IOms | $uptime"
