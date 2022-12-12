#!/bin/bash

source /opt/qnx_backup_and_recovery/config.sh
source /opt/qnx_backup_and_recovery/common.sh

[ ! -d $BACKUP_ROOT ] && echo >&2 "Backup directory does not exist: $BACKUP_ROOT" && exit -1
[ ! -w $BACKUP_ROOT ] && echo >&2 "The backup directory is not writeable: $BACKUP_ROOT" && exit -1

[ ! -f $PATHS_LIST ] && echo >&2 "Paths list file does not exist: $PATHS_LIST" && exit -1
[ ! -r $PATHS_LIST ] && echo >&2 "The paths list file is not readable: $PATHS_LIST" && exit -1

[ ! -f $HOSTS_LIST ] && echo >&2 "Hosts list file does not exist: $HOSTS_LIST" && exit -1
[ ! -r $HOSTS_LIST ] && echo >&2 "The hosts list file is not readable: $HOSTS_LIST" && exit -1

command -v rsync >/dev/null 2>&1 || { echo >&2 "rsync it's not installed"; exit -1; }

echo "Lista hostów:"
hosts_counter=0
mapfile hosts_list < $HOSTS_LIST
for ix in ${!hosts_list[*]}
do
	timestamp=$(date +%Y%m%d_%H%M%S.%N)
	row=`echo ${hosts_list[$ix]} | sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//'`
	[[ $row == "" ]] && continue
	addr=( $(grep -o '^.\+[[:blank:]]' <<<"$row") )
	common.validate_ip_addr ${addr} || continue
	host=( $(grep -o '[[:blank:]].\+$' <<<"$row") )
	common.validate_hostname ${host} || continue
	printf "  [${hosts_counter}] ${host} ${addr}\n"
	hosts[$hosts_counter]=${host};
	((hosts_counter++))
done
echo

while read -p 'Proszę wybrać hosta z listy ([q] - wyjście): ' idx
do
	case $idx in
		q ) echo Kończe prace.; exit;;
		* ) if ! [[ "$idx" =~ ^[0-9]+$ ]] || (( $idx < 0 )) || (( $idx >= $hosts_counter ));
			then echo "Nieprawidłowy wybór"
			else break;
			fi;;
	esac
done
host=${hosts[$idx]}

while read -p 'Proszę podać adres IP komputera docelowego: ' addr
do
	if common.validate_ip_addr ${addr}
	then break;
	fi
	echo "Niepoprawny adres IP"
done

while read -p "Rozpocząć przywracanie komputera ${host} (t/n): " acknowledgement
do
	case $acknowledgement in
		n ) echo Kończe prace.; exit;;
		t ) break;;
		* ) echo "Nieprawidłowy wybór";;
	esac
done
echo

printf "Przywracam ${host}...\n"
rsync -av -Rr --files-from=${PATHS_LIST} --log-file=${host}_$(date +%Y%m%d_%H%M%S.%N).log ${BACKUP_ROOT}/${host}${path} root@${addr}:/RECOVERY/
printf "OK.\n"
