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

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.dto.BaseDto;


/**
 * IssSyncOrg - Class representation of the table rhnsyncorgs.
 * @version $Rev: 1 $
 */
public class IssSyncOrg extends BaseDto {

    public static final Long NO_MAP_ID = new Long(-1L);

    private Long id;
    private Long sourceOrgId;
    private String sourceOrgName;
    private Org targetOrg;
    private IssOrgCatalogue catalogue;

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
     * Getter for sourceOrgId
     * @return Long to get
    */
    public Long getSourceOrgId() {
        return this.sourceOrgId;
    }

    /**
     * Setter for sourceOrgId
     * @param sourceOrgIdIn to set
    */
    public void setSourceOrgId(Long sourceOrgIdIn) {
        this.sourceOrgId = sourceOrgIdIn;
    }

    /**
     * Getter for sourceOrgName
     * @return String to get
    */
    public String getSourceOrgName() {
        return this.sourceOrgName;
    }

    /**
     * Setter for sourceOrgName
     * @param sourceOrgNameIn to set
    */
    public void setSourceOrgName(String sourceOrgNameIn) {
        this.sourceOrgName = sourceOrgNameIn;
    }

    /**
     *
     * @return target org associated with this source-org
     */
    public Org getTargetOrg() {
        return this.targetOrg;
    }

    /**
     *
     * @param targetOrgIn target org to be associated with this source org
     */
    public void setTargetOrg(Org targetOrgIn) {
        this.targetOrg = targetOrgIn;
    }

    /**
     *
     * @return master-node that owns this source-org
     */
    public IssOrgCatalogue getCatalogue() {
        return this.catalogue;
    }

    /**
     *
     * @param catalogueIn master node that should own this org
     */
    public void setCatalogue(IssOrgCatalogue catalogueIn) {
        this.catalogue = catalogueIn;
    }

}
