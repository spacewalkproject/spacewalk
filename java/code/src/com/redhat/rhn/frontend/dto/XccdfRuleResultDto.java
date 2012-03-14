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
public class XccdfRuleResultDto {

    private String system;
    private String identifier;
    private String label;

    /**
     * Returns the xccdf:rule-result system
     * @return the system
     */
    public String getSystem() {
        return this.system;
    }

    /**
     * Sets the xccdf:rule-result system
     * @param systemIn to set
     */
    public void setSystem(String systemIn) {
        this.system = systemIn;
    }

    /**
     * Returns the xccdf:ident
     * @return the ident
     */
    public String getIdentifier() {
        return this.identifier;
    }

    /**
     * Sets the xccdf:ident
     * @param identifierIn to set
     */
    public void setIdentifier(String identifierIn) {
        this.identifier = identifierIn;
    }

    /**
     * Returns the actual xccdf:rule-result result
     * @return the result
     */
    public String getLabel() {
        return label;
    }

    /**
     * Sets the actual xccdf:rule-result result
     * @param labelIn to set
     */
    public void setLabel(String labelIn) {
        label = labelIn;
    }
}
