#!/bin/bash

VERSION=v1.1.4
curl -L https://gitlab.dkrz.de/k202009/libaec/-/archive/${VERSION}/libaec-${VERSION}.tar.gz -o libaec.tar.gz
tar -xf libaec.tar.gz
rm libaec.tar.gz

rm -rf vendor/libaec
mv libaec-${VERSION} vendor/libaec 

rm -rf vendor/libaec/.git
rm -rf vendor/libaec/.github
rm -rf vendor/libaec/data
rm -rf vendor/libaec/doc
rm -rf vendor/libaec/fuzzing
rm -rf vendor/libaec/tests
