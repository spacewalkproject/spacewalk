#!/bin/sh
SEARCH_HOME=..
NUTCH_HOME=/usr/share/nutch

CLASSPATH=${CLASSPATH}:${SEARCH_HOME}/build
#Put our nutch/conf dir before the NUTCH_HOME so ensure our config files are used
CLASSPATH=${CLASSPATH}:${SEARCH_HOME}/nutch/conf
CLASSPATH=${CLASSPATH}:${NUTCH_HOME}
for f in ${SEARCH_HOME}/lib/*.jar; do
    CLASSPATH=${CLASSPATH}:$f;
done

java -cp ${CLASSPATH} com.redhat.satellite.search.scheduler.tasks.crawl.WebCrawl --inputUrlFile ${SEARCH_HOME}/nutch/urls --outputDir ./crawl_output --docsIndexDir ./docsIndexDir --depth 2 --threads 4 




