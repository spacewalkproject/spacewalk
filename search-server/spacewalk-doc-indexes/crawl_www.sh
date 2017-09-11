#!/bin/bash


if [ "${JAVA_HOME}" = "" ]; then
    export JAVA_HOME=/usr/lib/jvm/java
    echo "Setting JAVA_HOME to: ${JAVA_HOME}"
fi

export NUTCH_HOME=/usr/share/nutch
export NUTCH_CONF_DIR=`pwd`/crawl_www/conf
export NUTCH_OPTS=
export NUTCH_LOG_DIR=`pwd`/logs
export OUTPUT_DIR=`pwd`/data/crawl_www

echo "NUTCH_HOME = ${NUTCH_HOME}"
echo "NUTCH_CONF_DIR = ${NUTCH_CONF_DIR}"
echo "NUTCH_OPTS = ${NUTCH_OPTS}"
echo "NUTCH_LOG_DIR = ${NUTCH_LOG_DIR}"
echo "OUTPUT_DIR = ${OUTPUT_DIR}"

if [ ! -d ${NUTCH_LOG_DIR} ]; then
    echo "Creating log directory ${NUTCH_LOG_DIR}"
    mkdir ${NUTCH_LOG_DIR}
fi

if [ ! -d ${OUTPUT_DIR} ]; then
    echo "Creating output directory ${OUTPUT_DIR}"
    mkdir -p ${OUTPUT_DIR}
fi

# The original command - newer versions of nutch use separate crawl command
# ${NUTCH_HOME}/bin/nutch crawl ${NUTCH_CONF_DIR}/../urls -dir ${OUTPUT_DIR} -depth 10 -threads 50 | tee ${NUTCH_LOG_DIR}/$0.log

# This new command is supposed to do crawl and index all at once.  But it fails when it attempts the nutch clean command below.  So run without the -i to skip indexing and then do indexing in separate step
${NUTCH_HOME}/bin/crawl -i -D solr.server.url=http://localhost:8983/solr/spacewalk ${NUTCH_CONF_DIR}/../urls ${OUTPUT_DIR} 10 | tee ${NUTCH_LOG_DIR}/$0.log

# The command that fails as part of the crawl with indexing enabled
# /usr/share/nutch/bin/nutch clean -Dsolr.server.url=http://localhost:8983/solr/spacewalk /home/rdu/eherget/sources/spacewalk/search-server/spacewalk-doc-indexes/data/crawl_www/crawldb

# The crawl command without indexing.  This actually works
# ${NUTCH_HOME}/bin/crawl -D solr.server.url=http://localhost:8983/solr/spacewalk ${NUTCH_CONF_DIR}/../urls ${OUTPUT_DIR} 10 | tee ${NUTCH_LOG_DIR}/$0.log

# The command for indexing the crawl from command immediately above this one
# ${NUTCH_HOME}/bin/nutch solrindex http://localhost:8983/solr/spacewalk ${OUTPUT_DIR}/crawldb -linkdb ${OUTPUT_DIR}/linkdb -dir ${OUTPUT_DIR}/segments -filter -normalize -deleteGone
