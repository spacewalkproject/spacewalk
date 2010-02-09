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
package com.redhat.rhn.frontend.dto.monitoring;

import com.redhat.rhn.frontend.dto.BaseDto;

/**
 * A DTO for displaying the description of a probe together
 * with the name of the server it is associated with
 * @version $Rev$
 */
public class CheckProbeDto extends BaseDto {

    private Long id;
    private String     description;
    private Long serverId;
    private String     serverName;
    
    /**
     * {@inheritDoc}
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @return Returns the description.
     */
    public String getDescription() {
        return description;
    }
    
    /**
     * @return Returns the serverId.
     */
    public Long getServerId() {
        return serverId;
    }
    
    /**
     * @return Returns the serverName.
     */
    public String getServerName() {
        return serverName;
    }
    
    /**
     * @param description0 The description to set.
     */
    public void setDescription(String description0) {
        description = description0;
    }
    
    /**
     * @param id0 The id to set.
     */
    public void setId(Long id0) {
        id = id0;
    }

    
    /**
     * @param serverId0 The serverId to set.
     */
    public void setServerId(Long serverId0) {
        serverId = serverId0;
    }

    
    /**
     * @param serverName0 The serverName to set.
     */
    public void setServerName(String serverName0) {
        serverName = serverName0;
    }
    
    /**
     * @return a label that indicates probe description and server name
     */
    public String getLabel() {
        return description + " [" + serverName + "]";
    }

}
