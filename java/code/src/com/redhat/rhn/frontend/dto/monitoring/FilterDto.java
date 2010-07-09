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
package com.redhat.rhn.frontend.dto.monitoring;

import com.redhat.rhn.frontend.dto.BaseDto;

import java.util.Date;

/**
 * DTO for a com.redhat.rhn.domain.monitoring.notification.Filter
 * @version $Rev: 50942 $
 */
public class FilterDto extends BaseDto {

    private Long recid;
    private String redirectType;
    private String description;
    private Date expiration;

    /**
     * {@inheritDoc}
     */
    public Long getId() {
        return recid;
    }

    /**
     * @return Returns the description.
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
     * @return Returns the expiration.
     */
    public Date getExpiration() {
        return expiration;
    }

    /**
     * @param expirationIn The expiration to set.
     */
    public void setExpiration(Date expirationIn) {
        this.expiration = expirationIn;
    }

    /**
     * @return Returns the recid.
     */
    public Long getRecid() {
        return recid;
    }

    /**
     * @param recidIn The recid to set.
     */
    public void setRecid(Long recidIn) {
        this.recid = recidIn;
    }

    /**
     * @return Returns the redirectType.
     */
    public String getRedirectType() {
        return redirectType;
    }

    /**
     * @param redirectTypeIn The redirectType to set.
     */
    public void setRedirectType(String redirectTypeIn) {
        this.redirectType = redirectTypeIn;
    }

}
