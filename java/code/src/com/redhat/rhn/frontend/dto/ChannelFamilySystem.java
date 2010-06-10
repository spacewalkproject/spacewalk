/**
 * Copyright (c) 2010 Red Hat, Inc.
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

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.frontend.struts.SelectableAdapter;

import java.util.Date;


/**
 * ChannelFamilySystem
 * @version $Rev$
 */
public class ChannelFamilySystem extends SelectableAdapter {
    private String name;
    private Long id;
    private boolean active;
    private Date registered;
    private ChannelFamilySystemGroup group;
    
    /**
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }
    
    
    /**
     * @return Returns the group.
     */
    public ChannelFamilySystemGroup getGroup() {
        return group;
    }

    
    /**
     * @param groupIn The group to set.
     */
    public void setGroup(ChannelFamilySystemGroup groupIn) {
        group = groupIn;
    }

    /**
     * @param nameIn The name to set.
     */
    public void setName(String nameIn) {
        name = nameIn;
    }
    
    /**
     * @return Returns the active.
     */
    public boolean isActive() {
        return active;
    }
    
    /**
     * @param activeIn The active to set.
     */
    public void setActive(boolean activeIn) {
        active = activeIn;
    }
    
    /**
     * @return Returns the registered.
     */
    public Date getRegistered() {
        return registered;
    }
    
    /**
     * @return Returns the registered.
     */
    public String  getRegisteredString() {
        return StringUtil.categorizeTime(registered.getTime(), StringUtil.YEARS_UNITS);
    }        
    /**
     * @param registeredIn The registered to set.
     */
    public void setRegistered(Date registeredIn) {
        registered = registeredIn;
    }
    
    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        id = idIn;
    }
    
    /**
     * @return returns server id
     */
    public Long getId() {
        return id;
    }
    /**
     * {@inheritDoc}
     */
    public String getSelectionKey() {
        return group.getId() + "|" + id;
    }
}
