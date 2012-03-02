/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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

import java.util.Date;

/**
 * SystemGroupOverview
 * @version $Rev$
 */
public class SystemGroupOverview extends BaseDto {

    private Long id;
    private String name;
    private Long groupAdmins;
    private Long serverCount;
    private Date modified;
    private Long maxMembers;
    private String monitoringStatus;
    private String mostSevereErrata;


    /**
     * Gets the most severe errata type
     * @return the most severe errata type
     */
    public String getMostSevereErrata() {
        return mostSevereErrata;
    }

    /**
     * Set most Severe Errata type
     * @param mostSevereErrataIn the most severe errata type
     */
    public void setMostSevereErrata(String mostSevereErrataIn) {
        this.mostSevereErrata = mostSevereErrataIn;
    }

    /**
     * set if this is selected with a Long
     * @param selectedIn 1 if it was selected, 0 if not
     */
    public void setSelected(Long selectedIn) {
           setSelected(selectedIn.intValue() != 0);
    }

    /**
     * @return Returns the groupAdmins.
     */
    public Long getGroupAdmins() {
        return groupAdmins;
    }
    /**
     * @param groupAdminsIn The groupAdmins to set.
     */
    public void setGroupAdmins(Long groupAdminsIn) {
        this.groupAdmins = groupAdminsIn;
    }
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }
    /**
     * @return Returns the maxMembers.
     */
    public Long getMaxMembers() {
        return maxMembers;
    }
    /**
     * @param maxMembersIn The maxMembers to set.
     */
    public void setMaxMembers(Long maxMembersIn) {
        this.maxMembers = maxMembersIn;
    }
    /**
     * @return Returns the modified.
     */
    public Date getModified() {
        return modified;
    }
    /**
     * @param modifiedIn The modified to set.
     */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }
    /**
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }
    /**
     * @param nameIn The name to set.
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }
    /**
     * @return Returns the serverCount.
     */
    public Long getServerCount() {
        return serverCount;
    }
    /**
     * @param serverCountIn The serverCount to set.
     */
    public void setServerCount(Long serverCountIn) {
        this.serverCount = serverCountIn;
    }

    /**
     * @return Returns the monitoringStatus.
     */
    public String getMonitoringStatus() {
        return monitoringStatus;
    }

    /**
     * @param monitoringStatusIn The monitoringStatus to set.
     */
    public void setMonitoringStatus(String monitoringStatusIn) {
        this.monitoringStatus = monitoringStatusIn;
    }

}
