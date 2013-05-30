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
 * IssMaster - Class representation of the table rhnissmaster.
 * @version $Rev: 1 $
 */
public class IssMaster extends BaseDto {

    public static final String ID = "id";
    public static final String LABEL = "label";

    private Long id;
    private String label;
    private Set<IssMasterOrgs> masterOrgs;

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
    public Set<IssMasterOrgs> getMasterOrgs() {
        return this.masterOrgs;
    }

    /**
     * Set the orgs for this master
     * @param inOrgs orgs of the master that we know of
     */
    public void setMasterOrgs(Set<IssMasterOrgs> inOrgs) {
        this.masterOrgs = inOrgs;
    }

    /**
     * How many orgs did Master tell us about? (NOTE: we add this because you can't
     * do ${current.orgs.size} in the JSPs :( )
     * @return number of orgs from this master we know of
     */
    public int getNumMasterOrgs() {
        return getMasterOrgs().size();
    }

    /**
     * How many master-orgs have been mapped?
     * @return number of unique master-orgs that have non-null local orgs
     */
    public int getNumMappedMasterOrgs() {
        int mappedSources = 0;
        for (IssMasterOrgs so : getMasterOrgs()) {
            if (so.getLocalOrg() != null) {
                mappedSources++;
            }
        }
        return mappedSources;
    }

}
