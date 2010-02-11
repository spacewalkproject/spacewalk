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
package com.redhat.rhn.frontend.dto.kickstart;

import com.redhat.rhn.frontend.dto.BaseDto;

/**
 * KickstartOverviewSummaryDto
 * @version $Rev$
 */
public class KickstartOverviewSummaryDto extends BaseDto {
    private String name;
    private Long id;
    private int numberOfProfiles;
    private String label;
    
    
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @param idIn The idIn to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }
        
    /**
     * @return Returns a count of Kickstarts
     * associated with this RHEL.
     */
    public int getNumberOfProfiles() {
        return numberOfProfiles;
    }

    /**
     * @param nopIn The number of profiles to set.
     */
    public void setNumberOfProfiles(int nopIn) {
        this.numberOfProfiles = nopIn;
    }

    /**
     * @return Returns label of install type
     */
    public String getLabel() {
        return label;
    }

    /**
     * @param labelIn The labelIn to set.
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     * @return Returns the rhel software name.
     */
    public String getName() {
        return name;
    }
    
    /**
     * @param nameIn The nameIn to set.
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }
}
