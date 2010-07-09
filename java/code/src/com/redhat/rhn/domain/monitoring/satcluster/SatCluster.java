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
package com.redhat.rhn.domain.monitoring.satcluster;

import com.redhat.rhn.domain.org.Org;

import java.util.Date;

/**
 * SatCluster - Class representation of the table rhn_sat_cluster.
 * @version $Rev: 1 $
 */
public class SatCluster {

    private Long id;
    private String targetType;
    private String description;
    private String lastUpdateUser;
    private Date lastUpdateDate;
    private String publicKey;
    private String vip;
    private String deployed;
    private String pemPublicKey;
    private String pemPublicKeyHash;

    private PhysicalLocation physicalLocation;
    private Org org;
    private CommandTarget commandTarget;

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
     * Getter for targetType
     * @return String to get
    */
    public String getTargetType() {
        return this.targetType;
    }

    /**
     * Setter for targetType
     * @param targetTypeIn to set
    */
    public void setTargetType(String targetTypeIn) {
        this.targetType = targetTypeIn;
    }

    /**
     * Getter for description
     * @return String to get
    */
    public String getDescription() {
        return this.description;
    }

    /**
     * Setter for description
     * @param descriptionIn to set
    */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }

    /**
     * Getter for lastUpdateUser
     * @return String to get
    */
    public String getLastUpdateUser() {
        return this.lastUpdateUser;
    }

    /**
     * Setter for lastUpdateUser
     * @param lastUpdateUserIn to set
    */
    public void setLastUpdateUser(String lastUpdateUserIn) {
        this.lastUpdateUser = lastUpdateUserIn;
    }

    /**
     * Getter for lastUpdateDate
     * @return Date to get
    */
    public Date getLastUpdateDate() {
        return this.lastUpdateDate;
    }

    /**
     * Setter for lastUpdateDate
     * @param lastUpdateDateIn to set
    */
    public void setLastUpdateDate(Date lastUpdateDateIn) {
        this.lastUpdateDate = lastUpdateDateIn;
    }

    /**
     * Getter for publicKey
     * @return String to get
    */
    public String getPublicKey() {
        return this.publicKey;
    }

    /**
     * Setter for publicKey
     * @param publicKeyIn to set
    */
    public void setPublicKey(String publicKeyIn) {
        this.publicKey = publicKeyIn;
    }

    /**
     * Getter for vip
     * @return String to get
    */
    public String getVip() {
        return this.vip;
    }

    /**
     * Setter for vip
     * @param vipIn to set
    */
    public void setVip(String vipIn) {
        this.vip = vipIn;
    }

    /**
     * Getter for deployed
     * @return String to get
    */
    public String getDeployed() {
        return this.deployed;
    }

    /**
     * Setter for deployed
     * @param deployedIn to set
    */
    public void setDeployed(String deployedIn) {
        this.deployed = deployedIn;
    }

    /**
     * Getter for pemPublicKey
     * @return String to get
    */
    public String getPemPublicKey() {
        return this.pemPublicKey;
    }

    /**
     * Setter for pemPublicKey
     * @param pemPublicKeyIn to set
    */
    public void setPemPublicKey(String pemPublicKeyIn) {
        this.pemPublicKey = pemPublicKeyIn;
    }

    /**
     * Getter for pemPublicKeyHash
     * @return String to get
    */
    public String getPemPublicKeyHash() {
        return this.pemPublicKeyHash;
    }

    /**
     * Setter for pemPublicKeyHash
     * @param pemPublicKeyHashIn to set
    */
    public void setPemPublicKeyHash(String pemPublicKeyHashIn) {
        this.pemPublicKeyHash = pemPublicKeyHashIn;
    }

    /**
     * @return Returns the physicalLocation.
     */
    public PhysicalLocation getPhysicalLocation() {
        return physicalLocation;
    }
    /**
     * @param physicalLocationIn The physicalLocation to set.
     */
    public void setPhysicalLocation(PhysicalLocation physicalLocationIn) {
        this.physicalLocation = physicalLocationIn;
    }

    /**
     * @return Returns the org.
     */
    public Org getOrg() {
        return org;
    }

    /**
     * @param orgIn The org to set.
     */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }

    /**
     * @return Returns the commandTarget.
     */
    public CommandTarget getCommandTarget() {
        return commandTarget;
    }

    /**
     * @param commandTargetIn The commandTarget to set.
     */
    public void setCommandTarget(CommandTarget commandTargetIn) {
        this.commandTarget = commandTargetIn;
    }
}
