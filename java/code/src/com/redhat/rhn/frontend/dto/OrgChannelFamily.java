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
package com.redhat.rhn.frontend.dto;


/**
 * OrgChannelFamily
 * @version $Rev$
 */
public class OrgChannelFamily extends ChannelOverview {

    private Long satelliteMaxMembers;
    private Long satelliteCurrentMembers;
    
    /**
     * @return Returns the satelliteMaxMembers.
     */
    public Long getSatelliteMaxMembers() {
        return satelliteMaxMembers;
    }
    
    /**
     * @param satelliteMaxMembersIn The satelliteMaxMembers to set.
     */
    public void setSatelliteMaxMembers(Long satelliteMaxMembersIn) {
        this.satelliteMaxMembers = satelliteMaxMembersIn;
    }
    
    /**
     * @return Returns the satelliteCurrentMembers.
     */
    public Long getSatelliteCurrentMembers() {
        return satelliteCurrentMembers;
    }
    
    /**
     * @param satelliteCurrentMembersIn The satelliteCurrentMembers to set.
     */
    public void setSatelliteCurrentMembers(Long satelliteCurrentMembersIn) {
        this.satelliteCurrentMembers = satelliteCurrentMembersIn;
    }
    
}
