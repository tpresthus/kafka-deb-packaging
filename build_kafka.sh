#!/bin/bash
# 2015-Mar-18 Updated to latest Kafka stable: 0.8.2.1
set -e
set -u
name=kafka
version=0.9.0.1
description="Apache Kafka is a distributed publish-subscribe messaging system."
url="https://kafka.apache.org/"
arch="all"
section="misc"
license="Apache Software License 2.0"
package_version="-1"
src_package="kafka-${version}-src.tgz"
download_url="http://mirror.sdunix.com/apache/kafka/${version}/${src_package}"
origdir="$(pwd)"

#_ MAIN _#
rm -rf ${name}*.deb
if [[ ! -f "${src_package}" ]]; then
  wget ${download_url}
fi
mkdir -p tmp && pushd tmp
rm -rf kafka
mkdir -p kafka
cd kafka
mkdir -p build/usr/lib/kafka
mkdir -p build/etc/default
mkdir -p build/etc/init
mkdir -p build/etc/kafka
mkdir -p build/var/log/kafka

cp ${origdir}/kafka-broker.default build/etc/default/kafka-broker
cp ${origdir}/kafka-broker.upstart.conf build/etc/init/kafka-broker.conf

tar zxf ${origdir}/${src_package}
cd kafka-${version}-src
sbt update
sbt package
mv config/log4j.properties config/server.properties ../build/etc/kafka
mv * ../build/usr/lib/kafka
cd ../build

fpm -t deb \
    -n ${name} \
    -v ${version}${package_version} \
    --description "${description}" \
    --url="{$url}" \
    -a ${arch} \
    --category ${section} \
    --vendor "" \
    --license "${license}" \
    -m "${USER}@localhost" \
    --prefix=/ \
    -s dir \
    -- .
mv kafka*.deb ${origdir}
popd
