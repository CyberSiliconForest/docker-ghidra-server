#!/bin/bash

set -e

pushd /ghidra/server

# Do templating stuff
cat jaas.conf.template |
  sed "s#__GHIDRA_LDAP_SERVER__#${GHIDRA_LDAP_SERVER}#g" |
  sed "s#__GHIDRA_LDAP_DN__#${GHIDRA_LDAP_DN}#g" > jaas.conf

./certificate.sh /certs/server.key /certs/server.crt

popd

if [ "$1" = 'server' ]; then
  shift
  # Figure out public address
  export GHIDRA_PUBLIC_HOSTNAME=${GHIDRA_PUBLIC_HOSTNAME:-$(dig +short myip.opendns.com @resolver1.opendns.com)}

  # Add users
  GHIDRA_USERS=${GHIDRA_USERS:-admin}
  if [ ! -e "/repos/users" ] && [ ! -z "${GHIDRA_USERS}" ]; then
    mkdir -p /repos/~admin
    for user in ${GHIDRA_USERS}; do
      echo "Adding user: ${user}"
      echo "-add ${user}" >> /repos/~admin/adm.cmd
    done
  fi

  exec "/ghidra/server/ghidraSvr" console
fi

exec "$@"
