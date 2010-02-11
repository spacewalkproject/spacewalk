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
package com.redhat.rhn.common;

import com.redhat.rhn.frontend.xmlrpc.LoggingInvocationProcessor;

import org.apache.log4j.Appender;
import org.apache.log4j.FileAppender;
import org.apache.log4j.Logger;
import org.apache.log4j.spi.ErrorHandler;
import org.apache.log4j.varia.FallbackErrorHandler;

/**
 * Simple log appender that falls back to the RootAppender (console)
 *      if an error occurs (like the user can't write to the log file)
 *      This is very helpful for user run unit tests.
 * FailbackAppender
 * @version $Rev$
 */
public class FailbackAppender extends FileAppender {

    /**
     * Constructor
     */
    public FailbackAppender() {
        ErrorHandler fb = new FallbackErrorHandler();
        this.setErrorHandler(fb);
        fb.setAppender(this);
        Appender rootAppen = Logger.getRootLogger().getAppender("RootAppender");
        
        if (rootAppen != null) {
            fb.setBackupAppender(rootAppen);
        }
        
        Logger logger = Logger.getLogger(LoggingInvocationProcessor.class);
        fb.setLogger(logger);
    }    
    
}
