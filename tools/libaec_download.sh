#!/bin/bash

VERSION=v1.1.4
curl -L https://gitlab.dkrz.de/k202009/libaec/-/archive/${VERSION}/libaec-${VERSION}.tar.gz -o libaec.tar.gz
tar -xf libaec.tar.gz
rm libaec.tar.gz

rm -rf libaec
mv libaec-${VERSION} libaec 

rm -rf libaec/data
rm -rf libaec/doc
rm -rf libaec/fuzzing
rm -rf libaec/tests
