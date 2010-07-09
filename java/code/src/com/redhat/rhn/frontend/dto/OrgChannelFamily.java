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

import com.redhat.rhn.domain.org.OrgFactory;


/**
 * OrgChannelFamily
 * @version $Rev$
 */
public class OrgChannelFamily extends ChannelOverview {

    private Long satelliteMaxMembers;
    private Long satelliteCurrentMembers;
    private Long satelliteMaxFlexMembers;
    private Long satelliteCurrentFlexMembers;

    /**
     * @return the key
     */
    public String getKey() {
        return makeKey(getId());
    }

    /**
     * @return the key
     */
    public String getFlexKey() {
        return makeFlexKey(getId());
    }


    /**
     * @param id the id of the channel family
     * @return the key
     */
    public static String makeKey(Long id) {
        return String.valueOf(id);
    }

    /**
     * @param id the id of the channel family
     * @return the key
     */
    public static String makeFlexKey(Long id) {
        return id + "-flex";
    }


    /**
     * @return Returns the satelliteMaxFlexMembers.
     */
    public Long getSatelliteMaxFlex() {
        return satelliteMaxFlexMembers;
    }


    /**
     * @param satelliteMaxFlexMembersIn The satelliteMaxFlexMembers to set.
     */
    public void setSatelliteMaxFlex(Long satelliteMaxFlexMembersIn) {
        satelliteMaxFlexMembers = satelliteMaxFlexMembersIn;
    }


    /**
     * @return Returns the satelliteCurrentFlexMembers.
     */
    public Long getSatelliteCurrentFlex() {
        return satelliteCurrentFlexMembers;
    }


    /**
     * @param satelliteCurrentFlexMembersIn The satelliteCurrentFlexMembers to set.
     */
    public void setSatelliteCurrentFlex(Long satelliteCurrentFlexMembersIn) {
        satelliteCurrentFlexMembers = satelliteCurrentFlexMembersIn;
    }

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

    /**
     * the maximum number of the available slots
     * @return the number of slots
     */
    public long getMaxAvailable() {
        if (OrgFactory.getSatelliteOrg().getId().equals(getOrgId())) {
            return getMaxMembers();
        }
        return getSatelliteMaxMembers() - getSatelliteCurrentMembers() + getMaxMembers();
    }

    /**
     * the maximum number of the available flex slots
     * @return the number of slots
     */
    public long getMaxAvailableFlex() {
        if (OrgFactory.getSatelliteOrg().getId().equals(getOrgId())) {
            return getMaxFlex();
        }
        return getSatelliteMaxFlex() - getSatelliteCurrentFlex() + getMaxFlex();
    }
}
