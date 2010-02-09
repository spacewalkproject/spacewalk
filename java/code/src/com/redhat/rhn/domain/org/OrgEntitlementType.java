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

package com.redhat.rhn.domain.org;

import com.redhat.rhn.domain.BaseDomainHelper;

/**
 * OrgEntitlementType
 * @version $Rev$
 */
public class OrgEntitlementType extends BaseDomainHelper {

    private Long id;
    private String label;
    private String name;

    /**
     * Default Constructor
     */
    public OrgEntitlementType() {
    }
   
    /**
     * Constructs an OrgEntitlementType by label and id.
     * @param labelIn Entitlement label
     * @param idIn Entitlement ID
     */
    public OrgEntitlementType(String labelIn, Long idIn) {
        id = idIn;
        label = labelIn;
    }

    /**
     * Constructs an OrgEntitlementType by label and id.
     * @param labelIn Entitlement label
     */
    public OrgEntitlementType(String labelIn) {
        label = labelIn;
    }
    
    /** 
    * Getter for id 
    * @return Long id of this object
    */
    public Long getId() {
        return this.id;
    }

    /** 
     * Setter for id 
     * @param idIn id to set
    */
    public void setId(Long idIn) {
        this.id = idIn;
    }
    
    /** 
    * Getter for label 
    * @return String label
    */
    public String getLabel() {
        return this.label;
    }

    /** 
    * Setter for label 
    * @param labelIn new label to set
    */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /** 
    * Getter for name 
    * @return String Name of OE
    */
    public String getName() {
        return this.name;
    }

    /** 
     * Setter for name 
     * @param nameIn new name to set
    */
    public void setName(String nameIn) {
        this.name = nameIn;
    }
    
    /** {@inheritDoc} */
    public String toString() {
        StringBuffer retval = new StringBuffer();
        retval.append("Entitlement: ");
        retval.append(label);
        return retval.toString();
    }
    
    /** {@inheritDoc} */
    public boolean equals(Object ent) {
        // Compaire based on the label only
        OrgEntitlementType oet = (OrgEntitlementType) ent;
        return (oet.getLabel().equals(label));
    }
    
    /** {@inheritDoc} */
    public int hashCode() {
        return label.hashCode();
    }
}
