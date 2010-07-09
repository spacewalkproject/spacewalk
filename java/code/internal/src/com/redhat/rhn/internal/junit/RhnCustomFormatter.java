/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
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
package com.redhat.rhn.internal.junit;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.optional.junit.JUnitResultFormatter;
import org.apache.tools.ant.taskdefs.optional.junit.JUnitTest;
import org.apache.tools.ant.taskdefs.optional.junit.JUnitTestRunner;
import org.apache.tools.ant.taskdefs.optional.junit.JUnitVersionHelper;

import java.io.IOException;
import java.io.OutputStream;
import java.text.MessageFormat;
import java.text.NumberFormat;
import java.util.Hashtable;

import junit.framework.AssertionFailedError;
import junit.framework.Test;
import junit.framework.TestListener;

/**
 * A more spartan custom ant results logger, shamelessly hacked out
 * from PlainJUnitResultsFormatter from ant.
 *
 * It's hideous.
 *
 * @version $Rev$
 */
public class RhnCustomFormatter implements JUnitResultFormatter, TestListener {

    private static final double MS_PER_S = 1000.0;

    /** formatter for timings. */
    private NumberFormat nf = NumberFormat.getInstance();

    /** storage for test start times */
    private Hashtable testStarts;

    /** storage for listing failed tests */
    private Hashtable failed;

    /** the output stream where to write the log to. */
    private OutputStream out;

    /**
     * Creates a new <code>RhnCustomFormatter</code> instance.
     */
    public RhnCustomFormatter() {
        testStarts = new Hashtable();
        failed = new Hashtable();
    }

    /**
     * Sets the internal output stream
     * @param ostream the output stream
     */
    public void setOutput(OutputStream ostream) {
        out = ostream;
    }

    /**
     * Saves what was written to stdout
     * @param outStr the String representing what was written to stdout
     */
    public void setSystemOutput(String outStr) { }

    /**
     * Saves what was written to stderr
     * @param errStr the String represnting what was written to stderr
     */
    public void setSystemError(String errStr) { }

    /**
     * called when a test suite starts to run
     * @param suite a <code>JUnitTest</code> value
     */
    public void startTestSuite(JUnitTest suite) {
        StringBuffer sb = new StringBuffer();

        Object [] args = {
            "Running ",
            suite.getName()
        };

        MessageFormat form = new MessageFormat("{0} {1}\n");

        sb.append(form.format(args));

        if (out != null) {
            try {
                out.write(sb.toString().getBytes());
                out.flush();
            }
            catch (IOException ioex) {
                throw new BuildException("Unable to write output", ioex);
            }
            // DO NOT CLOSE the out stream!!!
        }
    }

    private void buildSummaryMsg(JUnitTest suite, StringBuffer sb) {
        Object [] args = {
            new Long(suite.runCount()),
            new Long(suite.failureCount()),
            new Long(suite.errorCount()),
            nf.format(suite.getRunTime() / RhnCustomFormatter.MS_PER_S)
        };

        MessageFormat form = new MessageFormat(
            "Tests run: {0}, Failures: {1}, Errors: {2} Time elapsed: {3} sec\n");

        sb.append(form.format(args));
    }

    private void buildResultsMsg(JUnitTest suite, StringBuffer sb) {
        Object [] args = {
            suite.getName(),
            nf.format(suite.getRunTime() / RhnCustomFormatter.MS_PER_S),
            "ok"
        };

        MessageFormat form = new MessageFormat("{0}({1}s):  {2}\n\n");

        long problemCount = suite.failureCount() + suite.errorCount();
        if (problemCount > 0) {
            args[2] = problemCount + " NOT OK";
        }

        sb.append(form.format(args));
    }

    /**
     * called when the test suite finishes running.
     * most of the interesting stuff happens here.
     * prints out the overall timing, and success,
     * or any failures that occur
     * @param suite a <code>JUnitTest</code>
     * @exception BuildException if an error occurs
     */
    public void endTestSuite(JUnitTest suite) throws BuildException {
        StringBuffer sb = new StringBuffer();

        buildSummaryMsg(suite, sb);

        buildResultsMsg(suite, sb);


        if (out != null) {
            try {
                out.write(sb.toString().getBytes());
                out.flush();
            }
            catch (IOException ioex) {
                throw new BuildException("Unable to write output", ioex);
            }
            finally {
                if (out != System.out && out != System.err) {
                    try {
                        out.close();
                    }
                    catch (IOException ioex2) {
                        System.out.println(ioex2);
                    }
                }
            }
        }
    }

    /**
     * Interface TestListener.
     * <p>A new Test is started.
     * @param t the test
     */
    public void startTest(Test t) {
        testStarts.put(t, new Long(System.currentTimeMillis()));
        failed.put(t, Boolean.FALSE);
    }

    /**
     * Interface TestListener.
     * <p>A Test is finished.
     * @param test the test
     */
    public void endTest(Test test) { }

    /**
     * Interface TestListener for JUnit &lt;= 3.4.
     *
     * <p>A Test failed.
     * @param test the Test that failed
     * @param t the Throwable that occurred
     */
    public void addFailure(Test test, Throwable t) {
        formatError("\tFAILED", test, t);
    }

    /**
     * Interface TestListener for JUnit &gt; 3.4.
     *
     * <p>A Test failed.
     * @param test the Test that failed
     * @param t the Throwable that occurred
     */
    public void addFailure(Test test, AssertionFailedError t) {
        addFailure(test, (Throwable) t);
    }

    /**
     * Interface TestListener.
     *
     * <p>An error occured while running the test.
     * @param test the Test that failed
     * @param t the Throwable that occurred
     */
    public void addError(Test test, Throwable t) {
        formatError("\tCaused an ERROR", test, t);
    }


    private void formatError(String type, Test test, Throwable t) {
        synchronized (out) {
            if (test != null) {
                endTest(test);
                failed.put(test, Boolean.TRUE);
            }

            Object[] args = {
                JUnitVersionHelper.getTestCaseName(test),
                type,
                t.getMessage(),
                JUnitTestRunner.getFilteredTrace(t),
            };

            MessageFormat form = new MessageFormat("\n{0}:  {2}\n{3}\n");
            try {
                out.write(form.format(args).getBytes());
                out.flush();
            }
            catch (IOException ioex) {
                throw new BuildException("Unable to write output", ioex);
            }
            // DO NOT CLOSE the out stream!!!
        }
    }
}
