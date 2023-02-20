#!/bin/bash

rm -f keystore.jks

openssl pkcs12 -inkey "$1" -in "$2" -export -passout pass:password -out certificate.p12
keytool -importkeystore -srckeystore certificate.p12 -srcstoretype pkcs12 -srcstorepass password -destkeystore keystore.jks -deststoretype pkcs12 -storepass 'password'

rm -f certificate.p12
