#!/bin/bash

common.validate_ip_addr () {
	[[ $1 =~ ^((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]|[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]|[0-9])$ ]] || return 1
	return 0
}

common.validate_hostname () {
	[[ $1 =~ ^[[:alpha:]]([[:alnum:]]|_)+$ ]] || return 1
	return 0
}

