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
package com.redhat.rhn.frontend.events;

import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.manager.errata.cache.UpdateErrataCacheCommand;

import org.apache.log4j.Logger;

/**
 * UpdateErrataCacheAction
 * @version $Rev$
 */
public class UpdateErrataCacheAction extends AbstractDatabaseAction {
    
    private static Logger log = Logger.getLogger(UpdateErrataCacheAction.class);

    /** {@inheritDoc} */
    protected void doExecute(EventMessage msg) {
        UpdateErrataCacheEvent evt = (UpdateErrataCacheEvent) msg;
        if (log.isDebugEnabled()) {
            log.debug("Updating errata cache, with type: " + evt.getUpdateType());
        }

        UpdateErrataCacheCommand uecc = new UpdateErrataCacheCommand();
        
        if (evt.getUpdateType() == UpdateErrataCacheEvent.TYPE_ORG) {
            Long orgId = evt.getOrgId();
            if (orgId == null) {
                log.error("UpdateErrataCacheEvent was sent with a null org");
                return;
            }
            if (log.isDebugEnabled()) {
                log.debug("Updating errata cache for org [" + orgId + "]");
            }
            uecc.updateErrataCache(orgId);
            if (log.isDebugEnabled()) {
                log.debug("Finished updating errata cache for org [" +
                        orgId + "]");
            }
        }
        else if (evt.getUpdateType() == UpdateErrataCacheEvent.TYPE_CHANNEL) {
            for (Long cid : evt.getChannelIds()) {
                if (log.isDebugEnabled()) {
                    log.debug("Updating errata cache for channel: " + cid);
                }
                uecc.updateErrataCacheForChannel(cid);
            }
        }
        else if (evt.getUpdateType() == UpdateErrataCacheEvent.TYPE_CHANNEL_ERRATA) {
            for (Long cid : evt.getChannelIds()) {
                if (log.isDebugEnabled()) {
                    log.debug("Updating errata cache for channel: " + cid + 
                            " and errata:" + evt.getErrataId());
                }
                if (evt.getPackageIds() == null || evt.getPackageIds().size() == 0) {
                    uecc.updateErrataCacheForErrata(cid, evt.getErrataId());    
                }
                else {
                    uecc.updateErrataCacheForErrata(cid, evt.getErrataId(), 
                            evt.getPackageIds());  
                }
            }
        }
        else {
            throw new IllegalArgumentException("Unknown update type: " + 
                    evt.getUpdateType());
        }
        
    }

}
