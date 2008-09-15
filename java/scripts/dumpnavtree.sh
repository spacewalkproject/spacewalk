#!/bin/sh
java -cp `build-classpath-directory ../build/run-lib/` com.redhat.rhn.scripts.DumpNavTree $1
