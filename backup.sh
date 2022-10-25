#!/bin/bash

source config.sh
source common.sh

[ ! -d $BACKUP_ROOT ] && echo >&2 "Backup directory does not exist: $BACKUP_ROOT" && exit -1
[ ! -w $BACKUP_ROOT ] && echo >&2 "The backup directory is not writeable: $BACKUP_ROOT" && exit -1

[ ! -f $PATHS_LIST ] && echo >&2 "Paths list file does not exist: $PATHS_LIST" && exit -1
[ ! -r $PATHS_LIST ] && echo >&2 "The paths list file is not readable: $PATHS_LIST" && exit -1

[ ! -f $HOSTS_LIST ] && echo >&2 "Hosts list file does not exist: $HOSTS_LIST" && exit -1
[ ! -r $HOSTS_LIST ] && echo >&2 "The hosts list file is not readable: $HOSTS_LIST" && exit -1

command -v rsync >/dev/null 2>&1 || { echo >&2 "rsync it's not installed"; exit -1; }

mapfile hosts < $HOSTS_LIST
for ix in ${!hosts[*]}
do
	timestamp=$(date +%Y%m%d_%H%M%S.%N)
	row=`echo ${hosts[$ix]} | sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//'`
	[[ $row == "" ]] && continue
	addr=( $(grep -o '^.\+[[:blank:]]' <<<"$row") )
	common.validate_ip_addr ${addr} || continue
	host=( $(grep -o '[[:blank:]].\+$' <<<"$row") )
	common.validate_hostname ${host} || continue
	printf "${timestamp} ${addr} ${host}\n"
	mkdir -p ${BACKUP_ROOT}/${host} || continue
	rsync -av -Rr --files-from=paths.list root@${addr}:/ ${BACKUP_ROOT}/${host}
	echo ${timestamp} > ${BACKUP_ROOT}/${host}/LAST_BACKUP
	rsync -av ${BACKUP_ROOT}/${host}/LAST_BACKUP root@${addr}:/
	echo
done

