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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.frontend.struts.Expandable;

import java.util.LinkedList;
import java.util.List;


/**
 * ChannelSystemGrouping
 * @version $Rev$
 */
public class ChannelFamilySystemGroup implements Identifiable, Expandable {

    private String name;
    private Long id;
    private List<ChannelFamilySystem> systems = new LinkedList<ChannelFamilySystem>();
    private Long currentMembers;
    private Long maxMembers;

    /**
     * @return the entitlements count message
     */
    public String getEntitlementCountMessage() {
        LocalizationService ls = LocalizationService.getInstance();
        if (maxMembers == null) {
            return ls.getMessage("flexguest.jsp.entitlement_counts_message_unlimited",
                                                            currentMembers);
        }
        String key = "flexguest.jsp.entitlement_counts_message";
        long available = maxMembers - currentMembers;
        if (available > 1) {
            key = key + "_1";
        }
        
        return ls.getMessage(key, currentMembers, available);
    }

    /**
     * @param currentMembersIn The currentMembers to set.
     */
    public void setCurrentMembers(Long currentMembersIn) {
        currentMembers = currentMembersIn;
    }
    
    /**
     * @param maxMembersIn The maxMembers to set.
     */
    public void setMaxMembers(Long maxMembersIn) {
        maxMembers = maxMembersIn;
    }

    /**
     * {@inheritDoc}
     */
    public Long getId() {
        return id;
    }
    
    /**
     * adds a system to the grouping
     * @param sys a System overview object
     */
    public void add(ChannelFamilySystem sys) {
        systems.add(sys);
        sys.setGroup(this);
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
        name = nameIn;
    }

    
    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        id = idIn;
    }

    /**
     * 
     * {@inheritDoc}
     */
    public List<ChannelFamilySystem> expand() {
        return systems;
    }

}
