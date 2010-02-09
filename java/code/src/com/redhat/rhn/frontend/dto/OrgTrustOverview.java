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
 * 
 * OrgDto class represents Trusted Org lists
 * @version $Rev$
 */
public class OrgTrustOverview extends BaseDto {
    private Long id;
    private String name;
    private Boolean trusted;

    /**
     * 
     * {@inheritDoc}
     */
    public Long getId() {
        return id;
    }
    
    /**
     * 
     * @param idIn OrgIn Id 
     */
    public void setId(Long idIn) {
        id = idIn;
    }
    
    /**
     * 
     * @return Name of Org
     */
    public String getName() {
        return name;
    }
    
    /**
     * 
     * @param nameIn of Org to set
     */
    public void setName(String nameIn) {
        name = nameIn;
    }

    /**
     * 
     * @return whether the org is trusted.
     */
    public Boolean getTrusted() {
        return trusted;
    }

    /**
     * 
     * @param trustedIn whether the org is trusted.
     */
    public void setTrusted(Boolean trustedIn) {
        trusted = trustedIn;
    }
    
    /**
     * 
     * @param trustedIn whether the org is trusted.
     */
    public void setTrusted(Integer trustedIn) {
        trusted = (trustedIn != 0);
    }
}
