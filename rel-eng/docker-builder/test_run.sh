#!/usr/bin/bash

set -e

GITROOT=$(pwd)/$(git rev-parse --show-cdup)

docker run --rm --privileged=true -v $GITROOT:/git:z -v /tmp/:/out:z -e PACKAGE=backend -e DIST=spacewalk-nightly-el7 spacewalkproject/docker-builder

docker run --rm --privileged=true -v $GITROOT:/git:z -v /tmp/:/out:z -e PACKAGE=backend -e DIST=spacewalk-nightly-fedora27 spacewalkproject/docker-builder
