#!/bin/bash

source config.sh
source common.sh

[ ! -f $HOSTS_LIST ] && echo >&2 "Hosts list file does not exist: $HOSTS_LIST" && exit -1
[ ! -r $HOSTS_LIST ] && echo >&2 "The hosts list file is not readable: $HOSTS_LIST" && exit -1

mapfile hosts < $HOSTS_LIST
for ix in ${!hosts[*]}
do
	timestamp=$(date +%Y%m%d_%H%M%S.%N)
	row=`echo ${hosts[$ix]} | sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//'`
	[[ $row == "" ]] && continue
	addr=( $(grep -o '^.\+[[:blank:]]' <<<"$row") )
	common.validate_ip_addr $addr || continue
	host=( $(grep -o '[[:blank:]].\+$' <<<"$row") )
	common.validate_hostname $host || continue
	printf "${timestamp} ${host} ${addr} mkdir /pro/exe_apl\n"
	ssh root@${addr} mkdir /pro/exe_apl
done

