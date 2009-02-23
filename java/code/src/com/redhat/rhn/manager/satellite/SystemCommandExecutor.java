/**
 * Copyright (c) 2009 Red Hat, Inc.
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
import java.io.InputStreamReader;
import java.io.IOException;
import java.util.Arrays;

/**
 * SystemCommandExecutor - implementation of the Executor interface that
 * will take in the list of arguments and call Runtime.exec().
 * @version $Rev$
 */
public class SystemCommandExecutor implements Executor {

    /**
     * Logger for this class
     */
    private static Logger logger = Logger
            .getLogger(SystemCommandExecutor.class);

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
            
            /* read output of the command, if any */
            BufferedReader input = new BufferedReader(
                new InputStreamReader(p.getInputStream()));
            try {
                String line = input.readLine();
                while (line != null) {
                    line = input.readLine();
                }
            }
            catch (IOException ioe) {
                logger.debug("IOException...really need better handling here");
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

}
