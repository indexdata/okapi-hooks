#!/bin/bash

set -e # exit on error
set -x # echo commands

call_curl() {
	if test -n "${CURL_TOK}"; then
		curl -w '\n' -s ${CURL_TOK} $*
	else
		curl -w '\n' -s $*
	fi
}

post() {
	call_curl -XPOST -HContent-Type:application/json $*
}

delete() {
	call_curl -XDELETE $*
}

login() {
	if test "${OKAPI_TOKEN}" = none; then
		return
	fi
	if test -z "${OKAPI_TOKEN}"; then
		if test -z "$OKAPI_USER" -o -z "$OKAPI_PASS"; then
			echo "No OKAPI_TOKEN; OKAPI_USER and OKAPI_PASS required"
			exit 1
		fi
		tmp=`mktemp`
		post -f -D$tmp -d"{\"username\":\"${OKAPI_USER}\",\"password\":\"${OKAPI_PASS}\"}" $U/authn/login
		OKAPI_TOKEN=`awk '/x-okapi-token/ {print $2}' < $tmp|tr -d '[:space:]'`
	fi
	CURL_TOK="-HX-Okapi-Token:${OKAPI_TOKEN}"
}

# TODO: handle that previous instance is a different version
hook_pre_delete() {
	for T in $OKAPI_TENANTS; do
		echo "[{\"id\":\"${SVCID}\",\"action\":\"disable\"}]" | post -d @- $U/_/proxy/tenants/$T/install
	done
	delete "$U/_/discovery/modules/${SVCID}/${INSTID}"
	delete "$U/_/proxy/modules/${SVCID}"
}

hook_post_install() {
	echo $OKAPI_MD | post -f -d @- $U/_/proxy/modules
	echo "{\"srvcId\":\"$SVCID\",\"instId\":\"${INSTID}\",\"url\":\"${MODULE_URL}\"}" | post -f -d @- $U/_/discovery/modules
	for T in $OKAPI_TENANTS; do
		echo "[{ \"id\":\"${SVCID}\",\"action\":\"enable\"}]" | post -f -d @- $U/_/proxy/tenants/$T/install
	done
}

prepare() {
	fail=false
	if test -z "$OKAPI_TENANTS"; then
		echo "OKAPI_TENANTS not set"
		fail=true
	fi
	if test -z "$OKAPI_URL"; then
		echo "OKAPI_URL not set"
		fail=true
	fi
	U=$OKAPI_URL

	if test -z "$OKAPI_MD"; then
		echo "OKAPI_MD not set"
		fail=true
	fi
	if test -z "$MODULE_URL"; then
		echo "MODULE_URL not set"
		fail=true
	fi
	if ! which curl > /dev/null; then
		echo "curl not found"
		fail=true
	fi
	if ! which jq > /dev/null; then
		echo "jq not found"
		fail=true
	fi
	if $fail; then
		echo "Exiting"
		exit 1
	fi
	SVCID=`echo $OKAPI_MD | jq -r '.id'`
	INSTID=inst-${SVCID}
	OKAPI_TENANTS=$(echo "$OKAPI_TENANTS" | tr ',' ' ')
}

prepare
login

hook_pre_delete
hook_post_install
