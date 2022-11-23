#!/bin/bash

[ ! -v QNX_BACKUP_AND_RECOVERY_PATH ] && 
	echo >&2 "The environment variable QNX_BACKUP_AND_RECOVERY_PATH is not set." && exit -1

source ${QNX_BACKUP_AND_RECOVERY_PATH}/config.sh
source ${QNX_BACKUP_AND_RECOVERY_PATH}/common.sh

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
	printf "${timestamp} ${host} ${addr} copy rsync\n"
	scp -p rsync.qnx6 root@${addr}:/usr/bin/rsync
done

