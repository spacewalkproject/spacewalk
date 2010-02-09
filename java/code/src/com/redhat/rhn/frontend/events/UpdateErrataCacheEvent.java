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

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.messaging.EventDatabaseMessage;

import org.hibernate.Transaction;

import java.util.List;

/**
 * UpdateErrataCacheEvent - publish even to update the errata cache for an Org
 * or a set of Channels.
 * 
 * @version $Rev$
 */
public class UpdateErrataCacheEvent implements EventDatabaseMessage {

    private Long orgId;
    private List<Long> channelIds;
    private List<Long> packageIds;
    private Long errataId;
    private int type = TYPE_ORG;
    public static final int TYPE_ORG = 1;
    public static final int TYPE_CHANNEL = 2;
    public static final int TYPE_CHANNEL_ERRATA = 3;
    
    private Transaction txn;
     

    /**
     * default constructor
     * @param typeIn - type of update we want to do.  TYPE_ORG, TYPE_CHANNEL
     */
    public UpdateErrataCacheEvent(int typeIn) {
        orgId = null;
        type = typeIn;
        this.txn = HibernateFactory.getSession().getTransaction();
    }
    
    /**
     * {@inheritDoc}
     */
    public String toText() {
        // really a noop
        return "";
    }
    
    /**
     * returns the orgId associated with this event.
     * @return the orgId associated with this event.
     */
    public Long getOrgId() {
        return orgId;
    }
    
    /**
     * Sets the org to be updated.
     * @param orgIdIn OrgId to be updated.
     */
    public void setOrgId(Long orgIdIn) {
        orgId = orgIdIn;
    }
    
    /**
     * Get the update type of this event.  Either ORG or Channel. 
     * @return int TYPE.
     */
    public int getUpdateType() {
        return this.type;
    }

    
    /**
     * @return Returns the channels.
     */
    public List<Long> getChannelIds() {
        return this.channelIds;
    }

    
    /**
     * Add a Channel to the set of Channels to recalculate the Errata cache
     * for.
     * @param channelIdsIn to add to the list to process.
     */
    public void setChannels(List<Long> channelIdsIn) {             
        this.channelIds = channelIdsIn;
    }

    /**
     * {@inheritDoc}
     */
    public Transaction getTransaction() {
        return this.txn;
    }

    
    /**
     * @return Returns the errata_id.
     */
    public Long getErrataId() {
        return errataId;
    }

    
    /**
     * @param errataIdIn The errata_id to set.
     */
    public void setErrataId(Long errataIdIn) {
        this.errataId = errataIdIn;
    }

    
    /**
     * @return Returns the packageIds.
     */
    public List<Long> getPackageIds() {
        return packageIds;
    }

    
    /**
     * @param packageIdsIn The packageIds to set.
     */
    public void setPackageIds(List<Long> packageIdsIn) {
        this.packageIds = packageIdsIn;
    }
}
