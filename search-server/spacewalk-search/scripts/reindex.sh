#!/usr/bin/env sh

RHN_SEARCH_HOME="../"

for f in $RHN_SEARCH_HOME/lib/*.jar; do
    CLASSPATH=${CLASSPATH}:$f;
done
for f in $RHN_SEARCH_HOME/dist/*.jar; do
    CLASSPATH=${CLASSPATH}:$f;
done
export CLASSPATH

groovy Reindex.groovy

    
