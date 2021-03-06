#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  echo "Usage: $0 [-w] limit [-c] limit"
  exit 2;
fi

while getopts w:c:?h OPT
do
  case $OPT in
     w)
       WARNING="0.$OPTARG"
       ;;
     c)
       CRITICAL="0.$OPTARG"
       ;;
     \?|h)
       echo "Usage: $0 [-w] limit [-c] limit"
       exit 0
       ;;
  esac
done

cur=$(cat /proc/sys/net/netfilter/nf_conntrack_count)
max=$(cat /proc/sys/net/netfilter/nf_conntrack_max)
free=$((max-cur))

warn=$(printf "%4.0f" $(echo "$max * $WARNING" |bc))
crit=$(printf "%4.0f" $(echo "$max * $CRITICAL" |bc))

if [ $cur -le $warn ]; then
  echo "OK: free conntrack $free"
  exit 0;
elif [ $cur -ge $warn ] && [ $cur -lt $crit ]; then
  echo "WARNING: free conntrack $free"
  exit 1;
elif [ $cur -ge $crit ]; then
  echo "CRITICAL: free conntrack $free"
  exit 2;
fi
