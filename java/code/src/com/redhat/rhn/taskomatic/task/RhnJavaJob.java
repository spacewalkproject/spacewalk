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

import org.apache.log4j.Logger;


/**
 * RhnJavaJob
 * @version $Rev$
 */
public abstract class RhnJavaJob implements RhnJob {

    private Logger log = null;
    private RhnJobAppender appender = null;

    public Logger getLogger(Class clazz) {
        if (log == null) {
            log = Logger.getLogger(clazz);
            appender = new RhnJobAppender();
            log.addAppender(appender);
        }
        return log;
    }

    public String getLogOutput() {
         return appender.getOutputContent();
    }

    public String getLogError() {
        return appender.getErrorContent();
    }

    public void appendExceptionToLogError(Exception e) {
        log.error(e.getMessage());
        log.error(e.getCause());
    }
}
