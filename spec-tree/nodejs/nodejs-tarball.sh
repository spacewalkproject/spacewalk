#!/bin/sh

version=$(rpm -q --specfile --qf='%{version}\n' nodejs.spec | head -n1)
wget http://nodejs.org/dist/v${version}/node-v${version}.tar.gz
tar -zxf node-v${version}.tar.gz
rm -rf node-v${version}/deps/openssl
tar -zcf node-v${version}-stripped.tar.gz node-v${version}
