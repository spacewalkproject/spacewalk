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
package com.redhat.rhn.domain.server;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;


/**
 * GuestAndNonVirtHostView is a read-only <i>view</i> of a virtual instance/guest and its
 * host.
 * 
 * @see VirtualInstanceFactory
 * 
 * @version $Rev$
 */
public class GuestAndNonVirtHostView {
    
    private Long guestSystemId;
    private Long guestOrgId;
    private String guestName;
    private Long hostOrgId;
    private Long hostId;
    private String hostName;
    
    /**
     * Initializes a view.
     * 
     * @param guestId The guest system id
     * 
     * @param theGuestOrgId The guest org id
     * 
     * @param guestSystemName The guest system's name
     * 
     * @param theHostOrgId The host org id
     * 
     * @param theHostId The host id
     * 
     * @param theHostName The host system's name
     */
    public GuestAndNonVirtHostView(Long guestId, Long theGuestOrgId, 
            String guestSystemName, Long theHostOrgId, Long theHostId, String theHostName) {

        guestSystemId = guestId;
        guestOrgId = theGuestOrgId;
        guestName = guestSystemName;
        hostOrgId = theHostOrgId;
        hostId = theHostId;
        hostName = theHostName;
    }
    
    /**
     * Initializes a view.
     * 
     * @param guestId The guest system id
     * 
     * @param orgId The org id of the guest
     * 
     * @param guestSystemName The guest system's name
     */
    public GuestAndNonVirtHostView(Long guestId, Long orgId, 
            String guestSystemName) {
        
        guestSystemId = guestId;
        guestOrgId = orgId;
        guestName = guestSystemName;
    }
    
    /**
     * Return the guest system id.
     * 
     * @return The guest system id 
     */
    public Long getGuestId() {
        return guestSystemId;
    }
    
    /**
     * Return the guest org id.
     * 
     * @return The guest org id
     */
    public Long getGuestOrgId() {
        return guestOrgId;
    }

    /**
     * @return Returns the guestName.
     */
    public String getGuestName() {
        return guestName;
    }
    
    /**
     * Return the host org id.
     * 
     * @return The host org id
     */
    public Long getHostOrgId() {
        if (guestAndHostInSameOrg()) {
            return hostOrgId;
        }
        
        return null;
    }

    /**
     * @return Returns the hostId.
     */
    public Long getHostId() {
        if (guestAndHostInSameOrg()) {
            return hostId;
        }
        return null;
    }

    /**
     * @return Returns the hostName.
     */
    public String getHostName() {
        if (guestAndHostInSameOrg()) {
            return hostName;
        }
        return null;
    }

    /**
     * Return <code>true</code> if the guest org id and host org id are equal.
     * 
     * @return <code>true</code> if the guest org id and host org id are equal.
     */
    public boolean guestAndHostInSameOrg() {
        return guestOrgId.equals(hostOrgId);
    }

    /**
     * Two GuestAndNonVirtHost objects are considered equal if their <code>
     * virtualInstanceId</code> properties are equal.
     * 
     * @param object The object to test
     * 
     * @return <code>true</code> if <code>object</code> is a GuestAndNonVirtHostView and
     * the <code>virtualInstanceId</code> properties are equal.
     */
    public boolean equals(Object object) {
        if (object == null || object.getClass() != this.getClass()) {
            return false;
        }
        
        GuestAndNonVirtHostView that = (GuestAndNonVirtHostView)object;
        
        EqualsBuilder builder = new EqualsBuilder().append(this.guestSystemId,
                that.guestSystemId).append(this.guestOrgId, that.guestOrgId)
                .append(this.guestName, that.guestName);
        
        if (guestAndHostInSameOrg()) {
            builder.append(this.hostOrgId, that.hostOrgId).append(this.hostId, that.hostId)
                 .append(this.hostName, that.hostName);
        }
        
        return builder.isEquals();
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public int hashCode() {
        HashCodeBuilder builder = new HashCodeBuilder().append(guestSystemId)
                .append(guestOrgId).append(guestName);
        
        if (guestAndHostInSameOrg()) {
            builder.append(hostOrgId).append(hostId).append(hostName);
        }
        
        return builder.toHashCode();
    }
    
}
