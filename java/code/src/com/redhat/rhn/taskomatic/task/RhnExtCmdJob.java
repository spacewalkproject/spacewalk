/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.taskomatic.task;

import com.redhat.rhn.manager.satellite.SystemCommandExecutor;

import org.apache.log4j.Logger;


/**
 * RhnExtCmdJob
 * @version $Rev$
 */
public abstract class RhnExtCmdJob implements RhnJob {

    protected Logger log = null;
    private String stdOutput;
    private String stdError;

    public Logger getLogger(Class clazz) {
        if (log == null) {
            log = Logger.getLogger(clazz);
        }
        return log;
    }

    protected void executeExtCmd(String[] args) {
        SystemCommandExecutor ce = new SystemCommandExecutor();
        ce.execute(args);

        setStdOutput(ce.getLastCommandOutput());
        setStdError(ce.getLastCommandErrorMessage());
    }

    private void setStdError(String stdErrorIn) {
        stdError = stdErrorIn;
    }

    private void setStdOutput(String stdOutputIn) {
        stdOutput = stdOutputIn;
    }

    public String getLogOutput() {
        return stdOutput;
   }

   public String getLogError() {
       return stdError;
   }

   public void appendExceptionToLogError(Exception e) {
       e.printStackTrace();
       stdError += e.getMessage();
       stdError += e.getCause();
   }
}
