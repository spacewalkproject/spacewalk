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

import com.redhat.rhn.common.localization.LocalizationService;

import org.apache.log4j.AppenderSkeleton;
import org.apache.log4j.Level;
import org.apache.log4j.spi.LoggingEvent;

import java.util.Date;


/**
 * RhnJobAppender
 * @version $Rev$
 */
public class RhnJobAppender extends AppenderSkeleton {
    private StringBuffer outputBuffer = new StringBuffer();
    private StringBuffer errorBuffer = new StringBuffer();

    public String getOutputContent() {
        return outputBuffer.toString();
    }

    public String getErrorContent() {
        return errorBuffer.toString();
    }

    @Override
    protected void append(LoggingEvent event) {
        outputBuffer.append(logEvent(event));
        if (!Level.INFO.isGreaterOrEqual(event.getLevel())) {
            errorBuffer.append(logEvent(event));
        }
    }

    private String logEvent(LoggingEvent event) {
        return LocalizationService.getInstance().formatCustomDate(
                new Date(LoggingEvent.getStartTime())) + " [" + event.getThreadName() +
            "] " + event.getLevel() + " " + event.getClass().getName() + " " +
            event.getRenderedMessage() + '\n';
    }

    public void close() {
    }

    public boolean requiresLayout() {
        return false;
    }
}
