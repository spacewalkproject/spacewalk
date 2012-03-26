/**
 * Copyright (c) 2012 Red Hat, Inc.
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
 * Simple DTO for transfering data from the DB to the UI through datasource.
 * @version $Rev$
 */
public class XccdfIdentDto {

    private Long id;
    private String identifier;
    private String system;

    /**
     * Returns id of xccdf:ident
     * @return the id
     */
    public Long getId() {
        return this.id;
    }

    /**
     * Sets the id of xccdf:ident
     * @param idIn to set
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Returns the identifier of xccdf:ident
     * @return the identifier
     */
    public String getIdentifier() {
        return identifier;
    }

    /**
     * Sets the identifier of xccdf:ident
     * @param identifierIn to set
     */
    public void setIdentifier(String identifierIn) {
        identifier = identifierIn;
    }

    /**
     * Returns the naming system of xccdf:ident
     * @return the system
     */
    public String getSystem() {
        return system;
    }

    /**
     * Sets the naming system of xccdf:ident
     * @param systemIn to set
     */
    public void setSystem(String systemIn) {
        system = systemIn;
    }

    /**
     * Does this ident represent idref attribute?
     * Note: Each rule-result element in the XCCDF document
     * has 'idref' attribute which uniquely identifies
     * the xccdf:Rule and xccdf:rule-result elements.
     * @return true if this ident represent idref attribute
     */
    public boolean isDocumentIdref() {
        return "#IDREF#".equals(this.system);
    }
}
