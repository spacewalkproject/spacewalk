/**
 * Copyright (c) 2013 Red Hat, Inc.
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
package com.redhat.rhn.domain.iss;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
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
    private String isCurrentMaster = "N";
    private String caCert;
    private Set<IssMasterOrg> masterOrgs = new HashSet<IssMasterOrg>();

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
     * Get filename of CA Certificate for this master
     * @return filename
     */
    public String getCaCert() {
        return caCert;
    }

    /**
     * Set filename of the CA Cert for this master
     * @param caCertIn path to the CA cert for this master
     */
    public void setCaCert(String caCertIn) {
        this.caCert = caCertIn;
    }

    /**
     * Is this master the current-default for the Slave we're on?
     * @return 'Y' is we're the default, 'N' else
     */
    protected String getIsCurrentMaster() {
        return isCurrentMaster;
    }

    /**
     * Set this master as default, or not
     * NOTE: FOR HIBERNATE ONLY, use #makeDefaultMaster() instead
     * @param isCurrentIn - 'Y' if this is the default, 'N' else
     */
    protected void setIsCurrentMaster(String isCurrentIn) {
        this.isCurrentMaster = isCurrentIn;
    }

    /**
     * Make this master the default for this slave's satellite-sync operations
     */
    public void makeDefaultMaster() {
        IssFactory.unsetCurrentMaster();
        this.setIsCurrentMaster("Y");
    }

    /**
     * Make sure this master is NOT the default for satellite-sync
     * NOTE: Preferred is to make someone else the default -but sometimes, you
     * just don't want a default...
     */
    public void unsetAsDefault() {
        this.setIsCurrentMaster("N");
    }

    /**
     * Is this master the default for this slave's satellite-sync?
     * @return true if this is the master satellite-sync will use in the absence of
     * other info
     */
    public boolean isDefaultMaster() {
        return "Y".equals(this.getIsCurrentMaster());
    }

    /**
     * Get Orgs this master has let us know about
     * @return list of orgs Master has told us about
     */
    public Set<IssMasterOrg> getMasterOrgs() {
        return this.masterOrgs;
    }

    /**
     * Set the orgs for this master - protected, we want callers to either add-to the list,
     * or to give us a chance to do the Right Thing in terms of connecting the incoming
     * orgs and this master.  This API is used by Hibernate
     * @param inOrgs orgs of the master that we know of
     */
    protected void setMasterOrgs(Set<IssMasterOrg> inOrgs) {
        this.masterOrgs = inOrgs;
    }

    /**
     * Reset the orgs for this master to a new map
     * @param inOrgs orgs of the master that we know of
     */
    public void resetMasterOrgs(Set<IssMasterOrg> inOrgs) {
        setMasterOrgsInternal(inOrgs, true);
    }

    /**
     * Add a single new master-org, to this Master
     * @param org org to be added
     */
    public void addToMaster(IssMasterOrg org) {
        Set<IssMasterOrg> orgs = new HashSet<IssMasterOrg>();
        orgs.add(org);
        setMasterOrgsInternal(orgs, false);
    }

    private void setMasterOrgsInternal(Set<IssMasterOrg> inOrgs, boolean replace) {
        // Make sure everything incoming points to "us"
        Map<String, IssMasterOrg> findIncoming = new HashMap<String, IssMasterOrg>();
        for (IssMasterOrg org : inOrgs) {
            findIncoming.put(org.getMasterOrgName(), org);
            org.setMaster(this);
        }

        // If we're replacing, get rid of anything not in the incoming set
        if (replace) {
            this.masterOrgs.retainAll(inOrgs);
        }

        // Add to the Collection, letting Set "do the right thing" when master-orgs
        // are the same
        this.masterOrgs.addAll(inOrgs);

        // Fix up local-orgs
        setLocals(findIncoming);
    }

    // Make sure localOrgId is set correctly - we need this because having/not-having
    // a local-org-id doesn't make a MasterOrg different in the equals/hash sense, so
    // we can't rely on Set "doing the right thing" for it
    private void setLocals(Map<String, IssMasterOrg> findIncoming) {
        for (IssMasterOrg o : this.getMasterOrgs()) {
            if (findIncoming.containsKey(o.getMasterOrgName())) {
                IssMasterOrg fromIncoming = findIncoming.get(o.getMasterOrgName());
                o.setLocalOrg(fromIncoming.getLocalOrg());
            }
        }
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
        for (IssMasterOrg so : getMasterOrgs()) {
            if (so.getLocalOrg() != null) {
                mappedSources++;
            }
        }
        return mappedSources;
    }

    /**
     * @return hashCode based on id
     */
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((id == null) ? 0 : id.hashCode());
        return result;
    }

    /**
     * Equality based on id
     * @param obj The Thing we're comparing against
     * @return true if obj.Id equal our.Id, false else
     */
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        IssMaster other = (IssMaster) obj;
        if (id == null) {
            if (other.id != null) {
                return false;
            }
        }
        else if (!id.equals(other.id)) {
            return false;
        }
        return true;
    }

}
