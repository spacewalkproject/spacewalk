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
package com.redhat.rhn.manager.satellite;

import org.apache.log4j.Logger;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Arrays;

/**
 * SystemCommandExecutor - implementation of the Executor interface that
 * will take in the list of arguments and call Runtime.exec().
 */
public class SystemCommandExecutor implements Executor {

    private String lastCommandOutput;
    private String lastCommandError;

    /**
     * Logger for this class
     */
    private final Logger logger = Logger.getLogger(this.getClass());

    /**
     * {@inheritDoc}
     */
    public int execute(String[] args) {
        if (logger.isDebugEnabled()) {
            logger.debug("execute(String[] args=" + Arrays.asList(args) + ") - start");
        }

        Runtime r = Runtime.getRuntime();
        try {
            if (logger.isDebugEnabled()) {
                logger.debug("execute() - Calling r.exec ..");
            }
            Process p = r.exec(args);

            lastCommandOutput = inputStreamToString(p.getInputStream());
            if (logger.isDebugEnabled()) {
                logger.debug("Output from process execution: " + lastCommandOutput);
            }

            lastCommandError = inputStreamToString(p.getErrorStream());
            if (lastCommandError != null && lastCommandError.trim().length() > 0) {
                logger.error("Error encountered executing (args=" +
                             Arrays.asList(args) + ")");
                logger.error("Error message from process: " + lastCommandError);
            }

            try {
                if (logger.isDebugEnabled()) {
                    logger.debug("execute() - Calling p.waitfor ..");
                }
                return p.waitFor();
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
    }

    /**
     * {@inheritDoc}
     */
    public String getLastCommandOutput() {
        return lastCommandOutput;
    }

    /**
     * {@inheritDoc}
     */
    public String getLastCommandErrorMessage() {
        return lastCommandError;
    }

    /**
     * Reads the given input stream and returns a string containing its contents.
     *
     * @param in cannot be <code>null</code>
     * @return will not be <code>null</code> but may be the empty string
     */
    private String inputStreamToString(InputStream in) {
        StringBuffer sb = new StringBuffer();

        try {
            BufferedReader input = new BufferedReader(new InputStreamReader(in));

            String line;
            while ((line = input.readLine()) != null) {
                sb.append(line);
            }
        }
        catch (IOException e) {
            logger.warn("Error reading input from process input stream", e);
        }

        return sb.toString();
    }

}
