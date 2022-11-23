#!/bin/bash

[ ! -v QNX_BACKUP_AND_RECOVERY_PATH ] && 
	echo >&2 "The environment variable QNX_BACKUP_AND_RECOVERY_PATH is not set." && exit -1

BACKUP_ROOT=/backups/QNX
PATHS_LIST=${QNX_BACKUP_AND_RECOVERY_PATH}/paths.list
HOSTS_LIST=${QNX_BACKUP_AND_RECOVERY_PATH}/hosts.list

