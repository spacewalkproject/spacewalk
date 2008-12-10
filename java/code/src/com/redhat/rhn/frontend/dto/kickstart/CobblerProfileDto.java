/**
 * Copyright (c) 2008 Red Hat, Inc.
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

package com.redhat.rhn.frontend.dto.kickstart;

import org.cobbler.Profile;

import java.util.LinkedList;
import java.util.List;


/**
 * DTO to  represent a cobbler only profile
 * @author paji
 * @version $Rev$
 */
public class CobblerProfileDto extends KickstartDto {
    private String selectionKey;
    /**
     * {@inheritDoc}
     */
    @Override
    public boolean isCobbler() {
        return true;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean isActive() {
        return true;
    }    
    /**
     * {@inheritDoc} 
     */
    @Override
    public String getSelectionKey() {
        return selectionKey;
    }
    
    /**
     * Dummy method to return null for channel
     * @return dummy label
     */
    public String getChannelLabel() {
        return "";
    }
    
    /**
     * Create as CobblerProfileDto instance
     *  from the given Cobbler profile object
     * @param profile  the Cobbler profile object
     * @return the converted Dto instance
     */
    public static CobblerProfileDto create(Profile profile) {
        CobblerProfileDto dto = new CobblerProfileDto();
        dto.selectionKey = profile.getUid();
        dto.setCobblerId(profile.getId());
        dto.setLabel(profile.getName());
        return dto;
    }
    
    /**
     * Helper method to get a list of CobblerProfileDtos 
     * from a list of cobbler profiles
     * @param cProfiles list of Cobbler profiles
     * @return the list of cobbler profile dtos
     */
    public static List<CobblerProfileDto> toProfiles(List<Profile> cProfiles) {
        List <CobblerProfileDto> dtos = new LinkedList<CobblerProfileDto>();
        for (Profile p : cProfiles) {
            dtos.add(create(p));
        }
        return dtos;
    }    
}
