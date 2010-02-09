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

import java.util.List;

/**
 * Simple DTO for transfering data from the DB to the UI through datasource.
 * 
 * @version $Rev: 1651 $
 */
public class VisibleSystems extends BaseDto {
    private Long id;
    private String serverName;
    private List groupName;
    private boolean selectable;

    /**
     * get the id
     * @return the id
     */
    public Long getId() {
        return id;
    }

    /**
     * get the server name
     * @return the server name
     */
    public String getServerName() {
        return serverName;
    }
    
    /**
     * get the group name
     * @return the group name
     */
    public List getGroupName() {
        return groupName;
    }

    /**
     * Set the id
     * @param i the id to set.
     */
    public void setId(Long i) {
        id = i;
    }

    /**
     * Set the server name
     * @param s the server name to set.
     */
    public void setServerName(String s) {
        serverName = s;
    }
    
    /**
     * Set the group name
     * @param g the group name to set.
     */
    public void setGroupName(List g) {
        groupName = g;
    }
    
    /**
     * @param selectableIn Whether a server is selectable
     * one if selectable, null if not selectable
     */
    public void setSelectable(Long selectableIn) {
        selectable = (selectableIn != null);
    }
    
    /**
     * Tells whether a system is selectable for the SSM
     * All management and provisioning entitled servers are true
     * They are false otherwise
     * @return whether the current system is UI selectable
     */
    public boolean isSelectable() {
        return selectable;
    }

}

