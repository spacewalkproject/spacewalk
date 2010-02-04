/**
 * Copyright (c) 2008--2010 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */
package com.redhat.satellite.search.index.docs;

import org.apache.nutch.crawl.Injector;
import org.apache.nutch.crawl.Generator;
import org.apache.nutch.crawl.CrawlDb;
import org.apache.nutch.crawl.LinkDb;
import org.apache.nutch.fetcher.Fetcher;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.FileSystem;
import org.apache.nutch.parse.ParseSegment;
import org.apache.nutch.indexer.DeleteDuplicates;
import org.apache.nutch.indexer.IndexMerger;
import org.apache.nutch.indexer.Indexer;
import org.apache.nutch.util.HadoopFSUtil;
import org.apache.nutch.util.NutchConfiguration;
import org.apache.nutch.util.NutchJob;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.PosixParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;

import org.apache.commons.cli.ParseException;

import org.apache.log4j.Logger;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.io.IOException;


/**
Crawls a set of urls and indexes their content.
Based off of nutch's crawl
 *
 * @version $Rev:  $
 */
public class WebCrawl {
    private static Logger log = Logger.getLogger(WebCrawl.class);

    private Configuration conf;
    private JobConf job;
    private String inputUrlFile;
    private String tmpCrawlDir;
    private String outputIndexDir;

    private int depth;
    private int threads;
    private long topN;

    /**
     * Constructor
     */
    public WebCrawl() {
        conf = NutchConfiguration.create();
        conf.addResource("crawl-tool.xml");
        job = new NutchJob(conf);
        threads = job.getInt("fetcher.threads.fetch", 10);
        depth = 5;
        topN = Long.MAX_VALUE;
    }

    /**
     * @return Returns the dir used to store tmp crawl data
     */
    public String getTmpCrawlDir() {
        return tmpCrawlDir;
    }
    /**
     * @param tmpCrawlDirIn the dir used to store tmp crawl data
     */
    public void setTmpCrawlDir(String tmpCrawlDirIn) {
        tmpCrawlDir = tmpCrawlDirIn;
    }
    /**
     * @return Returns the file used to seed the url crawl
     */
    public String getInputUrlFile() {
        return inputUrlFile;
    }
    /**
     * @param inputUrlFileIn file used to seed the url crawl
     */
    public void setInputUrlFile(String inputUrlFileIn) {
        inputUrlFile = inputUrlFileIn;
    }
    /**
     * @return Returns the dir to store the index of the crawled docs
     */
    public String getOutputIndexDir() {
        return outputIndexDir;
    }
    /**
     * @param outputIndexDirIn the dir to store the index of the crawled docs
     */
    public void setOutputIndexDir(String outputIndexDirIn) {
        outputIndexDir = outputIndexDirIn;
    }
    /**
     * @return Returns the maximum depth of recursion allowed
     */
    public int getDepth() {
        return depth;
    }
    /**
     * @param depthIn the maximum depth of recursion allowed
     */
    public void setDepth(int depthIn) {
        depth = depthIn;
    }
    /**
     * @return Returns the maximum number of fetcher threads used
     */
    public int getThreads() {
        return threads;
    }
    /**
     * @param threadsIn the maximum number of fetcher threads used
     */
    public void setThreads(int threadsIn) {
        threads = threadsIn;
    }
    /**
     * @return Returns the maximum number of "out links" to follow in any given page
     */
    public long getTopN() {
        return topN;
    }
    /**
     * @param topNIn the maximum number of "out links" to follow in any given page
     */
    public void setTopN(long topNIn) {
        topN = topNIn;
    }

    protected String getDate() {
        return new SimpleDateFormat("yyyyMMddHHmmss").format(
                new Date(System.currentTimeMillis()));
    }

    /**
     * Uses nutch to crawl a list of ulrs defined in "inputUrlFile"
     * Temporary scratch storage is held at "tmpCrawlDir"
     * The desired output is an index of crawled pages, stored at "outputIndexDir"
     *
     * @return true when urls successfully crawled/indexed
     */
    @SuppressWarnings("deprecation")
    public boolean crawl() throws IOException {
        log.info("Performing crawl with following config options: ");
        log.info("inputUrlFile = " + inputUrlFile);
        log.info("tmpCrawlDir = " + tmpCrawlDir);
        log.info("outputIndexDir = " + outputIndexDir);
        log.info("threads = " + threads);
        log.info("depth = " + depth);
        log.info("topN = " + topN);

        Path inputPath = new Path(inputUrlFile);
        Path linkDb = new Path(tmpCrawlDir + "/linkdb");
        Path segments = new Path(tmpCrawlDir + "/segments");
        Path indexes = new Path(tmpCrawlDir + "/indexes");
        Path index = new Path(outputIndexDir);
        Path crawlDb = new Path(tmpCrawlDir + "/crawldb");

        Path tmpDir = job.getLocalPath("crawl" + Path.SEPARATOR + getDate());
        Injector injector = new Injector(conf);
        Generator generator = new Generator(conf);
        Fetcher fetcher = new Fetcher(conf);
        ParseSegment parseSegment = new ParseSegment(conf);
        CrawlDb crawlDbTool = new CrawlDb(conf);
        LinkDb linkDbTool = new LinkDb(conf);
        Indexer indexer = new Indexer(conf);
        DeleteDuplicates dedup = new DeleteDuplicates(conf);
        IndexMerger merger = new IndexMerger(conf);

        FileSystem fs = FileSystem.get(job);

        log.info("Create a new database (crawlDB) of link information");
        injector.inject(crawlDb, inputPath);

        for (int i = 0; i < depth; i++) {
            log.info("Generate a fetch list from info in the crawlDB.");
            Path segment = generator.generate(crawlDb, segments, -1, topN,
                System.currentTimeMillis());
            if (segment == null) {
                log.info("Stopping at depth = " + i + " instead of " + (depth - 1) +
                        "  - no more URLs to fetch.");
                break;
            }
            log.info("Fetch links");
            fetcher.fetch(segment, threads);  // fetch it
            if (!Fetcher.isParsing(job)) {
                log.info("Parsing Segment");
                parseSegment.parse(segment);    // parse it, if needed
            }
            Path[] p = new Path[1];
            p[0] = segment;
            log.info("Update CrawlDB");
            crawlDbTool.update(crawlDb, p, true, true); // update crawldb
        }

        linkDbTool.invert(linkDb, segments, true, true, false); // invert links

        // Delete old indexes
        if (fs.exists(indexes)) {
            log.info("Deleting old indexes: $indexes");
            fs.delete(indexes);
        }

        // Delete old index
        if (fs.exists(index)) {
            log.info("Deleting old merged index: $index");
            fs.delete(index);
        }

        // index, dedup & merge
        indexer.index(indexes, crawlDb, linkDb,
                fs.listPaths(segments, HadoopFSUtil.getPassAllFilter()));

        Path[] p = new Path[1];
        p[0] = indexes;
        dedup.dedup(p);
        merger.merge(fs.listPaths(indexes, HadoopFSUtil.getPassAllFilter()),
                index, tmpDir);
        log.info("Crawl finished");
        return true;
    }


    /**
     * Performs a web crawl:
     * @param args command line arguments
     */
    public static void main(String[] args) throws IOException {

        WebCrawl wCrawl = new WebCrawl();

        Options options = new Options();
        options.addOption("i", "inputUrlFile", true,
                "file holding 'urls' file to seed web page crawling");
        options.addOption("o", "outputDir", true, "temp crawl output dir");
        options.addOption("x", "docsIndexDir", true, "docs index output dir");
        options.addOption("t", "threads", true, "number of threads");
        options.addOption("d", "depth", true, "depth to recurse towards");
        options.addOption("n", "topN", true, "maximum number of out links to follow");
        options.addOption("h", "help", false, "print help message");

        CommandLineParser parser = new PosixParser();
        try {
            CommandLine line = parser.parse(options, args);

            if (line.hasOption("h")) {
                HelpFormatter formatter = new HelpFormatter();
                formatter.printHelp("WebCrawl", options);
                return;
            }
            if (line.hasOption("i")) {
                wCrawl.setInputUrlFile(line.getOptionValue("i"));
            }
            if (line.hasOption("x")) {
                wCrawl.setOutputIndexDir(line.getOptionValue("x"));
            }
            if (line.hasOption("o")) {
                wCrawl.setTmpCrawlDir(line.getOptionValue("o"));
            }
            if (line.hasOption("t")) {
                wCrawl.setThreads(Integer.parseInt(line.getOptionValue("t")));
            }
            if (line.hasOption("d)")) {
                wCrawl.setDepth(Integer.parseInt(line.getOptionValue("d")));
            }
            if (line.hasOption("n")) {
                wCrawl.setTopN(Integer.parseInt(line.getOptionValue("n")));
            }

        }
        catch (ParseException exp) {
            System.err.println("Parsing failed.  Reason: " + exp.getMessage());
        }

        if (!wCrawl.crawl()) {
            System.err.println("Error -- WebCrawl.crawl() Failed!");
        }
    }


}
