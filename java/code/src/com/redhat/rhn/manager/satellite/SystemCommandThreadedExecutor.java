/**
 * Copyright (c) 2013 Red Hat, Inc.
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
package com.redhat.rhn.manager.satellite;

import org.apache.log4j.Logger;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Arrays;

/**
 * SystemCommandThreadedExecutor - implementation of the Executor interface that
 * will take in the list of arguments and call Runtime.exec().
 */
public class SystemCommandThreadedExecutor implements Executor {

    private boolean logError;

    private class StreamThread extends Thread {
        private InputStream inputStream;
        private boolean logError;
        private Logger logger;
        public StreamThread(InputStream in, boolean err, Logger log) {
                inputStream = in;
                logError = err;
                logger = log;
        }
        public void run() {
            StringBuffer sb = new StringBuffer();
            try {
                BufferedReader input = new BufferedReader(
                                                new InputStreamReader(inputStream));

                String line;
                while ((line = input.readLine()) != null) {
                    sb.append(line);
                    sb.append('\n');
                }
            }
            catch (IOException e) {
                logger.warn("Error reading from process ", e);
            }
            if (sb.length() > 0) {
                if (logError) {
                    logger.error(sb.toString());
                }
                else {
                    logger.info(sb.toString());
                }
            }
       }
    }

    /**
     * Logger for this class
     */
    private final Logger logger;

    /**
     * Constructor
     * @param log Desired logger
     */
    public SystemCommandThreadedExecutor(Logger log) {
        logError = true;
        logger   = log;
    }

    /**
     * Whether to log errors as an ERROR within log4j
     *  Even if this is set to false, the error will still be logged
     *  with DEBUG priority
     * @param toLog true to log as an error
     */
    public void setLogError(boolean toLog) {
        logError = toLog;
    }


    /**
     * {@inheritDoc}
     */
    public int execute(String[] args) {
        if (logger.isDebugEnabled()) {
            logger.debug("execute(String[] args=" + Arrays.asList(args) + ") - start");
        }

        int retval;
        Runtime r = Runtime.getRuntime();
        try {
            if (logger.isDebugEnabled()) {
                logger.debug("execute() - Calling r.exec ..");
            }
            Process p = r.exec(args);

            Thread inStream  = new StreamThread(
                                                p.getInputStream(), false, logger);
            Thread errStream = new StreamThread(
                                                p.getErrorStream(), logError, logger);

            inStream.start();
            errStream.start();

            try {
                if (logger.isDebugEnabled()) {
                    logger.debug("execute() - Calling p.waitfor ..");
                }
                retval = p.waitFor();
                inStream.join();
                errStream.join();
            }
            catch (InterruptedException e) {
                throw new RuntimeException(
                        "InterruptedException while trying to exec: " + e);
            }
        }
        catch (IOException ioe) {
            logger.error("execute(String[])", ioe);

            String message = "";
            for (int i = 0; i < args.length; i++) {
                message = message + args[i] + " ";
            }
            logger.error("IOException while trying to exec: " + message, ioe);
            throw new RuntimeException(
                    "IOException while trying to exec: " + message, ioe);
        }

        return retval;
    }

    /**
     * {@inheritDoc}
     */
    public String getLastCommandOutput() {
        return "";
    }

    /**
     * {@inheritDoc}
     */
    public String getLastCommandErrorMessage() {
        return "";
    }

}
