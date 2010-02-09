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
 * HostAndGuestCountView is a read-only <i>view</i> of virtual host system and the number of
 * its guests. 
 * {@link ServerFactory#findVirtPlatformHostsByOrg(com.redhat.rhn.domain.org.Org)}
 * returns a set of HostAndGuestCountView objects.
 * 
 * @version $Rev$
 */
public class HostAndGuestCountView {
    
    private Long hostId;
    private String hostName;
    private int numberOfGuests;
    
    /**
     * Creates a new view.
     * 
     * @param theHostId The host id
     * @param theHostName The host name
     * @param guestCount The number of guests belonging to the host
     */
    public HostAndGuestCountView(Long theHostId, String theHostName, int guestCount) {
        this.hostId = theHostId;
        this.hostName = theHostName;
        numberOfGuests = guestCount;
    }
    
    /**
     * 
     * @return The host id
     */
    public Long getHostId() {
        return hostId;
    }
    
    /**
     * 
     * @return The host name
     */
    public String getHostName() {
        return hostName;
    }
    
    /**
     * 
     * @return The number of guests belonging to the host
     */
    public int getNumberOfGuests() {
        return numberOfGuests;
    }
    
    /**
     * Two HostAndGuestCountView objects are considered equal if they have the same value
     * for their <code>hostId</code> properties.
     * 
     * @param object The object to compare
     * 
     * @return <code>true</code> if <code>object</code> is a HostAndGuestCountView and has
     * the same <code>hostId</code> as this view, <code>false</code> otherwise.
     */
    public boolean equals(Object object) {
        if (object != null && object.getClass() != this.getClass()) {
            return false;
        }
        
        HostAndGuestCountView that = (HostAndGuestCountView)object;
        
        return new EqualsBuilder().append(this.getHostId(), that.getHostId()).isEquals();
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getHostId()).toHashCode();
    }

}
