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
package com.redhat.rhn.frontend.dto;


/**
 * SystemSearchResult
 * @version $Rev$
 */
public class SystemSearchResult extends SystemOverview {
    
    private String matchingField;
    private String hostname;
    private String description;

    
    /**
     * @return returns the data in the field 
     * that was searched on
     */
    public String getMatchingField() {
        return matchingField;
    }

    /**
     * @param matchingFieldIn The matchingField to set.
     */
    public void setMatchingField(String matchingFieldIn) {
        this.matchingField = matchingFieldIn;
    }
    
    /**
     * Takes care of cases where the DB will be returning numerical
     * instead of varchar vlues
     * @param matchingFieldIn matchingField to set
     */
    public void setMatchingField(Long matchingFieldIn) {
        this.matchingField = matchingFieldIn.toString();
    }

    /**
     * @return the hostname
     */
    public String getHostname() {
        return hostname;
    }

    /**
     * @param hostnameIn the hostname to set
     */
    public void setHostname(String hostnameIn) {
        this.hostname = hostnameIn;
    }

    /**
     * @return the description
     */
    public String getDescription() {
        return description;
    }

    /**
     * @param descriptionIn the description to set
     */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }
}
