/**
 * Copyright (c) 2013 Red Hat, Inc.
 * All Rights Reserved.
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
 *
 */
package com.redhat.rhn.domain.iss;

import java.util.Set;

import com.redhat.rhn.frontend.dto.BaseDto;

/**
 * IssOrgCatalogue - Class representation of the table rhnsyncorgcatalogue.
 * @version $Rev: 1 $
 */
public class IssOrgCatalogue extends BaseDto {

    public static final String ID = "id";
    public static final String LABEL = "label";

    private Long id;
    private String label;
    private Set<IssSyncOrg> srcOrgs;

    /**
     * Getter for id
     * @return Long to get
    */
    public Long getId() {
        return this.id;
    }

    /**
     * Setter for id
     * @param idIn to set
    */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Getter for label
     * @return String to get
    */
    public String getLabel() {
        return this.label;
    }

    /**
     * Setter for label
     * @param labelIn to set
    */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     * Get Orgs this master has let us know about
     * @return list of orgs Master has told us about
     */
    public Set<IssSyncOrg> getSourceOrgs() {
        return this.srcOrgs;
    }

    /**
     * Set the orgs for this master
     * @param inOrgs orgs of the master that we know of
     */
    public void setSourceOrgs(Set<IssSyncOrg> inOrgs) {
        this.srcOrgs = inOrgs;
    }

    /**
     * How many orgs did Master tell us about?
     * @return number of orgs from this master we know of
     */
    public int getNumSourceOrgs() {
        return getSourceOrgs().size();
    }

    /**
     * How many source-orgs have been mapped?
     * @return number of unique source-orgs that have non-null targets
     */
    public int getNumMappedSourceOrgs() {
        int mappedSources = 0;
        for (IssSyncOrg so : getSourceOrgs()) {
            if (so.getTargetOrg() != null) {
                mappedSources++;
            }
        }
        return mappedSources;
    }

}
