/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.frontend.events;

import java.util.Iterator;

import org.apache.log4j.Logger;

import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.common.messaging.MessageAction;
import com.redhat.rhn.manager.errata.cache.UpdateErrataCacheCommand;

/**
 * UpdateErrataCacheAction
 * @version $Rev$
 */
public class UpdateErrataCacheAction 
        extends AbstractDatabaseAction implements MessageAction {
    
    private static Logger log = Logger.getLogger(UpdateErrataCacheAction.class);
    
    /**
     * {@inheritDoc}
     */
    public void execute(EventMessage msgIn) {
        UpdateErrataCacheEvent evt = (UpdateErrataCacheEvent) msgIn;
        if (log.isDebugEnabled()) {
            log.debug("Updating errata cache, with type: " + evt.getUpdateType());
        }
        Long orgId = evt.getOrgId();
        if (orgId == null) {
            log.warn("UpdateErrataCacheEvent was sent with a null org");
            return;
        }
        
        UpdateErrataCacheCommand uecc = new UpdateErrataCacheCommand();
        
        
        if (evt.getUpdateType() == UpdateErrataCacheEvent.TYPE_ORG) {
            if (log.isDebugEnabled()) {
                log.debug("Updating errata cache for org [" + orgId + "]");
            }
            uecc.updateErrataCache(orgId);
        }
        else if (evt.getUpdateType() == UpdateErrataCacheEvent.TYPE_CHANNEL) {
            
            Iterator i = evt.getChannelIds().iterator();
            while (i.hasNext()) {
                Long cid = (Long) i.next();
                if (log.isDebugEnabled()) {
                    log.debug("Updating errata cache for channel: " + cid);
                }
                uecc.updateErrataCacheForChannel(cid);
            }
        }
        else {
            throw new IllegalArgumentException("Unknown update type: " + 
                    evt.getUpdateType());
        }
        
        // normally this is done by the SessionFilter, but in this thread
        // we don't have such a luxury.
        handleTransactions();
        
        if (log.isDebugEnabled()) {
            log.debug("Finished updating errata cache for org [" +
                    orgId + "]");
        }
    }


}
