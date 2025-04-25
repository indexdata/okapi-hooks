#!/bin/sh
# Just exercise the script a bit with local Okapi and the test module it contains
#
set -e
OKAPIHOME=../okapi

handler() {
	kill $MODPID
	kill $OKAPIPID
}
java -jar $OKAPIHOME/okapi-core/target/okapi-core-fat.jar dev 2>&1 >okapi.log &
OKAPIPID=$!
trap handler EXIT
java -jar $OKAPIHOME/okapi-test-module/target/okapi-test-module-fat.jar 2>&1 >test-module.log &
MODPID=$!
trap handler EXIT
sleep 1

export OKAPI_URL=http://localhost:9130
export MD_URL=http://localhost:8080
export OKAPI_TOKEN=bogus
export OKAPI_MD=`cat $OKAPIHOME/okapi-test-module/target/ModuleDescriptor.json`
export OKAPI_TENANTS="t1 t2"

SVCID=`echo $OKAPI_MD | jq -r '.id'`

for T in ${OKAPI_TENANTS}; do
	curl -s -HContent-Type:application/json -XPOST -d "{\"id\":\"$T\"}" $OKAPI_URL/_/proxy/tenants
done

./okapi-hooks.sh

for T in ${OKAPI_TENANTS}; do
	curl -f ${OKAPI_URL}/_/proxy/tenants/$T/modules/${SVCID}
done

