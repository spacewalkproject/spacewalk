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
package com.redhat.rhn.frontend.dto;


/**
 * CryptoKeyDto
 * @version $Rev$
 */
public class CryptoKeyDto extends BaseDto {

    private Long id;
    private Long orgId;
    private String label;
    private String description;

    /**
     * {@inheritDoc}
     */
    public Long getId() {
        return id;
    }

    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }


    /**
     * @return the description
     */
    public String getDescription() {
        return description;
    }


    /**
     * @param descriptionIn The description to set.
     */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }


    /**
     * @return the label
     */
    public String getLabel() {
        return label;
    }


    /**
     * @param labelIn The label to set.
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }


    /**
     * @return the orgId
     */
    public Long getOrgId() {
        return orgId;
    }


    /**
     * @param orgIdIn The orgId to set.
     */
    public void setOrgId(Long orgIdIn) {
        this.orgId = orgIdIn;
    }

}
