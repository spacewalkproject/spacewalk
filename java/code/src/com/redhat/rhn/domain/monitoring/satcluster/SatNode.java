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

import com.redhat.rhn.domain.server.Server;

import java.util.Date;

/**
 * SatNode - Class representation of the table rhn_sat_node.
 * @version $Rev: 1 $
 */
public class SatNode {

    private Long id;
    private String targetType;
    private String lastUpdateUser;
    private Date lastUpdateDate;
    private String macAddress;
    private Long maxConcurrentChecks;
    private String ip;
    private Long schedLogLevel;
    private Long sputLogLevel;
    private Long dqLogLevel;
    private String scoutSharedKey;
    private Server server;
    private SatCluster satCluster;
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
     * Getter for macAddress
     * @return String to get
    */
    public String getMacAddress() {
        return this.macAddress;
    }

    /**
     * Setter for macAddress
     * @param macAddressIn to set
    */
    public void setMacAddress(String macAddressIn) {
        this.macAddress = macAddressIn;
    }

    /**
     * Getter for maxConcurrentChecks
     * @return Long to get
    */
    public Long getMaxConcurrentChecks() {
        return this.maxConcurrentChecks;
    }

    /**
     * Setter for maxConcurrentChecks
     * @param maxConcurrentChecksIn to set
    */
    public void setMaxConcurrentChecks(Long maxConcurrentChecksIn) {
        this.maxConcurrentChecks = maxConcurrentChecksIn;
    }

    /**
     * Getter for ip
     * @return String to get
    */
    public String getIp() {
        return this.ip;
    }

    /**
     * Setter for ip
     * @param ipIn to set
    */
    public void setIp(String ipIn) {
        this.ip = ipIn;
    }

    /**
     * Getter for schedLogLevel
     * @return Long to get
    */
    public Long getSchedLogLevel() {
        return this.schedLogLevel;
    }

    /**
     * Setter for schedLogLevel
     * @param schedLogLevelIn to set
    */
    public void setSchedLogLevel(Long schedLogLevelIn) {
        this.schedLogLevel = schedLogLevelIn;
    }

    /**
     * Getter for sputLogLevel
     * @return Long to get
    */
    public Long getSputLogLevel() {
        return this.sputLogLevel;
    }

    /**
     * Setter for sputLogLevel
     * @param sputLogLevelIn to set
    */
    public void setSputLogLevel(Long sputLogLevelIn) {
        this.sputLogLevel = sputLogLevelIn;
    }

    /**
     * Getter for dqLogLevel
     * @return Long to get
    */
    public Long getDqLogLevel() {
        return this.dqLogLevel;
    }

    /**
     * Setter for dqLogLevel
     * @param dqLogLevelIn to set
    */
    public void setDqLogLevel(Long dqLogLevelIn) {
        this.dqLogLevel = dqLogLevelIn;
    }

    /**
     * Getter for scoutSharedKey
     * @return String to get
    */
    public String getScoutSharedKey() {
        return this.scoutSharedKey;
    }

    /**
     * Setter for scoutSharedKey
     * @param scoutSharedKeyIn to set
    */
    public void setScoutSharedKey(String scoutSharedKeyIn) {
        this.scoutSharedKey = scoutSharedKeyIn;
    }

    /**
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }
    /**
     * @param serverIn The server to set.
     */
    public void setServer(Server serverIn) {
        this.server = serverIn;
    }
    /**
     * @return Returns the satCluster.
     */
    public SatCluster getSatCluster() {
        return satCluster;
    }
    /**
     * @param satClusterIn The satCluster to set.
     */
    public void setSatCluster(SatCluster satClusterIn) {
        this.satCluster = satClusterIn;
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
