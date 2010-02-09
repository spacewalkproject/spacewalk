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
package com.redhat.rhn.manager.system;

import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.frontend.events.UpdateErrataCacheEvent;
import com.redhat.rhn.manager.BasePersistOperation;

import org.apache.commons.lang.time.StopWatch;
import org.apache.log4j.Logger;


/**
 * BaseUpdateChannelCommand
 * @version $Rev$
 */
public class BaseUpdateChannelCommand extends BasePersistOperation {

    /**
     * Logger for this class
     */
    private static Logger log = Logger
            .getLogger(BaseUpdateChannelCommand.class);

    /**
     * {@inheritDoc}
     */
    public ValidatorError store() {
        publishUpdateErrataCacheEvent();
        return null;
    }
    
    /**
     * Private helper method to create a new UpdateErrataCacheEvent and publish it to the
     * MessageQueue.
     * @param orgIn The org we're updating.
     */
    private void publishUpdateErrataCacheEvent() {
        StopWatch sw = new StopWatch();
        if (log.isDebugEnabled()) {
            log.debug("Updating errata cache");
            sw.start();
        }
        
        UpdateErrataCacheEvent uece = 
            new UpdateErrataCacheEvent(UpdateErrataCacheEvent.TYPE_ORG);
        uece.setOrgId(user.getOrg().getId());
        MessageQueue.publish(uece);
        
        if (log.isDebugEnabled()) {
            sw.stop();
            log.debug("Finished Updating errata cache. Took [" +
                    sw.getTime() + "]");
        }
    }


}
