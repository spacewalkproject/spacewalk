/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.domain.channel;

import java.util.Date;

/**
 * ChannelProduct - Class representation of the table rhnChannelProduct.
 * @version $Rev: 1 $
 */
public class ChannelProduct {

    private Long id;
    private String product;
    private String version;
    private String betaMarker;
    private Date created;
    private Date modified;
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
     * Getter for product
     * @return String to get
    */
    public String getProduct() {
        return this.product;
    }

    /**
     * Setter for product
     * @param productIn to set
    */
    public void setProduct(String productIn) {
        this.product = productIn;
    }

    /**
     * Getter for version
     * @return String to get
    */
    public String getVersion() {
        return this.version;
    }

    /**
     * Setter for version
     * @param versionIn to set
    */
    public void setVersion(String versionIn) {
        this.version = versionIn;
    }

    /**
     * Getter for betaMarker
     * @return String to get
    */
    private String getBetaMarker() {
        return this.betaMarker;
    }

    /**
     * Setter for betaMarker
     * @param betaIn to set
    */
    private void setBetaMarker(String betaIn) {
        this.betaMarker = betaIn;
    }

    /**
     * Whether the channel product is a betaMarker product
     * @return true if product is a betaMarker product, false otherwise
     */
    public boolean isBeta() {
        return this.betaMarker.equals("Y");
    }

    /**
     * Setter for whether the channel product is a betaMarker product or not
     * Can't be named setBetaMarker or hibernate wigs out
     * @param isBeta true if the product is a betaMarker product, false otherwise
     */
    public void setBeta(boolean isBeta) {
        if (isBeta) {
            this.setBetaMarker("Y");
        }
        else {
            this.setBetaMarker("N");
        }
    }

    /**
     * Getter for created
     * @return Date to get
    */
    public Date getCreated() {
        return this.created;
    }

    /**
     * Setter for created
     * @param createdIn to set
    */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /**
     * Getter for modified
     * @return Date to get
    */
    public Date getModified() {
        return this.modified;
    }

    /**
     * Setter for modified
     * @param modifiedIn to set
    */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }

}
