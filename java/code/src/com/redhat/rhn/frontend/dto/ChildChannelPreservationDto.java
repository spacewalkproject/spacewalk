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
import java.util.Map;


/**
 * ChildChannelPreservationDto
 * @version $Rev$
 */
public class ChildChannelPreservationDto {
    
    private Long oldChannelId;
    private String oldChannelName;
    
    private Long otherChannelId;
    private String otherChannelName;
    
    private Long systemsAffectedCount;
    private List<Map> systemsAffected;
    
    /**
     * @param oldChannelIdIn The oldChannelId to set.
     * @param oldChannelNameIn The oldChannelName to set.
     * @param otherChannelIdIn The otherChannelId to set.
     * @param otherChannelNameIn The otherChannelName to set.
     * @param systemsAffectedIn The systemsAffected to set.
     */
    public ChildChannelPreservationDto(Long oldChannelIdIn, String oldChannelNameIn,
            Long otherChannelIdIn, String otherChannelNameIn, 
            List<Map> systemsAffectedIn) {
        
        this.oldChannelId = oldChannelIdIn;
        this.oldChannelName = oldChannelNameIn;
        
        this.otherChannelId = otherChannelIdIn;
        this.otherChannelName = otherChannelNameIn;
        
        this.systemsAffected = systemsAffectedIn;
        this.systemsAffectedCount = new Long(systemsAffected.size());
    }

    /**
     * @return Returns the oldChannelName.
     */
    public String getOldChannelName() {
        return oldChannelName;
    }
    
    /**
     * @param oldChannelNameIn The oldChannelName to set.
     */
    public void setOldChannelName(String oldChannelNameIn) {
        this.oldChannelName = oldChannelNameIn;
    }
    
    /**
     * @return Returns the otherChannelName.
     */
    public String getOtherChannelName() {
        return otherChannelName;
    }
    
    /**
     * Set the other channel name. (used for both parent and new channel names, thus the
     * name other)
     * @param otherChannelNameIn The otherChannelName to set.
     */
    public void setOtherChannelName(String otherChannelNameIn) {
        this.otherChannelName = otherChannelNameIn;
    }
    
    /**
     * @return Returns the systemsAffectedCount.
     */
    public Long getSystemsAffectedCount() {
        return systemsAffectedCount;
    }
    
    /**
     * @param systemsAffectedCountIn The systemsAffectedCount to set.
     */
    public void setSystemsAffectedCount(Long systemsAffectedCountIn) {
        this.systemsAffectedCount = systemsAffectedCountIn;
    }

    
    /**
     * @param systemsAffectedIn The systemsAffected to set.
     */
    public void setSystemsAffected(List<Map> systemsAffectedIn) {
        this.systemsAffected = systemsAffectedIn;
    }
    
    /**
     * @return Returns the systemsAffected.
     */
    public List<Map> getSystemsAffected() {
        return this.systemsAffected;
    }

    
    /**
     * @return Returns the oldChannelId.
     */
    public Long getOldChannelId() {
        return oldChannelId;
    }

    
    /**
     * @param oldChannelIdIn The oldChannelId to set.
     */
    public void setOldChannelId(Long oldChannelIdIn) {
        this.oldChannelId = oldChannelIdIn;
    }

    
    /**
     * @return Returns the otherChannelId.
     */
    public Long getOtherChannelId() {
        return otherChannelId;
    }

    
    /**
     * @param otherChannelIdIn The otherChannelId to set.
     */
    public void setOtherChannelId(Long otherChannelIdIn) {
        this.otherChannelId = otherChannelIdIn;
    }
    
}
