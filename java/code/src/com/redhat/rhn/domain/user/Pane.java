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
package com.redhat.rhn.domain.user;

import com.redhat.rhn.manager.acl.AclManager;

import org.apache.commons.lang.builder.HashCodeBuilder;

/**
 * Pane. This is the domain object that contains the
 * data represented by a Pane observed by a user.
 * Note this class directly maps to RHNINFOPANE
 * thorough hibernate
 * @version $Rev$ This object represents
 */
public class Pane {

    public static final String TASKS = "tasks";
    public static final String CRITICAL_SYSTEMS = "critical-systems";
    public static final String CRITICAL_PROBES = "critical-probes";
    public static final String WARNING_PROBES = "warning-probes";
    public static final String SYSTEM_GROUPS = "system-groups-widget";
    public static final String LATEST_ERRATA = "latest-errata";
    public static final String INACTIVE_SYSTEMS = "inactive-systems";
    public static final String PENDING_ACTIONS = "pending-actions";
    public static final String RECENTLY_REGISTERED_SYSTEMS = "recently-registered-systems";
    
    public static final String[] ALL_PANES = {TASKS, CRITICAL_SYSTEMS, CRITICAL_PROBES,
        WARNING_PROBES, SYSTEM_GROUPS, LATEST_ERRATA, INACTIVE_SYSTEMS,
        PENDING_ACTIONS, RECENTLY_REGISTERED_SYSTEMS};
    /**
     * Maps to RHNINFOPANE.LABEL
     * This is more of a label prefix 
     * than an actual text value. 
     * preferences.${label}.name and preferences.${label}.description get used
     * while displaying the check boxes in Preferences page.
     */
    private String label;
    
    /**
     * Maps to RHNINFOPANE.ID
     */    
    private Long id;
    
    /**
     * Maps to RHNINFOPANE.ACL
     * This field holds the conditions
     * as to whether pane should be Accessible Or Not...
     * This uses the same format as the User ACLs...
     */    
    private String acl;

    /**
     * Returns a Dummy Instance of the Pane object, populating only 
     * the id column. This is useful for when the Pane object is
     * used in a compare. If you see the equal's method, you notice 
     * that 2 Panes are considered equal if their id's are equal.
     * So if I have a set of panes and want to retrieve the correct 
     * one, I can say something like panes.get(Pane.makeKey(Long.valueOf(10))); 
     * @param id the Id value of the desired pane.
     * @return a new instance of the Pane object with the give ID.
     */
    public static Pane makeKey(Long id) {
        Pane ip = new Pane();
        ip.setId(id);
        return ip;
    }

    /**
     * Retrieves id which is the primary key. 
     * Maps to RHNINFOPANE.ID 
     * @return id of the Pane
     */
    public Long getId() {
        return id;
    }

    /**
     * Sets the ID. Note this is only to be used by hibernate
     * because this serves as a primary key identifier for this object.
     * Thats the reason its made private. 
     * @param anId the ID value to be set.
     */
    private void setId(Long anId) {
        this.id = anId;
    }

    /**
     * Retrieves the  Label prefix. 
     * see the description of field 'label' for more information. 
     * @return the  Label prefix
     */
    public String getLabel() {
        return label;
    }
    
    /**
     * Retrieves the key that should be used by the LocalizationService
     * to retrieve the 'Name' value. Something like
     * localizationService.get(pane.getNameKey())
     * @return key in the format preferences.${label}.name 
     */

    public String getNameKey() {
        return "preferences." + getLabel() + ".name";
    }

    /**
     * Retrieves the key that should be used by the LocalizationService
     * to retrieve the 'Description' value. Something like
     * localizationService.get(pane.getDescriptionKey())
     * @return key in the format preferences.${label}.description 
     */
    public String getDescriptionKey() {
        return "preferences." + getLabel() + ".description";
    }

    private void setLabel(String l) {
        this.label = l;
    }

    /**
     * Retrieves the ACL values- set of conditions that determine whether the 
     * given pane should be visible to the user or not.. 
     * see the field description for more info. 
     * @return a string in the ACL format or null if none exists for the pane.
     */
    public String getAcl() {
        return acl;
    }

    private void setAcl(String aclValue) {
        this.acl = aclValue;
    }

    /**
     * This method determines if the given pane should be 
     * viewable to the current user
     * @param user the logged in user.
     * @return true if the pane is to be accessible.
     */
    public boolean isValidFor(User user) {
        return AclManager.hasAcl(getAcl(), user, 
                "com.redhat.rhn.common.security.acl.MonitoringAclHandler",
                        null);
    }
    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getId()).toHashCode();
    }

    /**
     * {@inheritDoc}
     * One important thing to note though is 
     * that only the Pane id is used  to differentiate between 2 Panes
     */
    public boolean equals(Object obj) {
        if (obj instanceof Pane) {

            if (obj == this) {
                return true;
            }

            Pane that = (Pane) obj;
            return this.getId().equals(that.getId());
        }
        return false;
    }
}
