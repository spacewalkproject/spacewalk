/**
 * Copyright (c) 2008--2013 Red Hat, Inc.
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

import java.util.Date;

import com.redhat.rhn.domain.org.Org;

/**
 * IssSlaveOrgs - Class representation of the table rhnissslaveorgs.
 * @version $Rev: 1 $
 */
public class IssSlaveOrgs {

    private Long id;
    private Long slaveId;
    private Long orgId;
    private Org org;
    private IssSlave slave;

    private Date created;
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
     * Getter for slaveId
     * @return Long to get
    */
    public Long getSlaveId() {
        return this.slaveId;
    }

    /**
     * Setter for slaveId
     * @param slaveIdIn to set
    */
    public void setSlaveId(Long slaveIdIn) {
        this.slaveId = slaveIdIn;
    }

    /**
     * Getter for orgId
     * @return Long to get
    */
    public Long getOrgId() {
        return this.orgId;
    }

    /**
     * Setter for orgId
     * @param orgIdIn to set
    */
    public void setOrgId(Long orgIdIn) {
        this.orgId = orgIdIn;
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
     * Get associated Org
     * @return Org associated w/the specified slave
     */
    public Org getOrg() {
        return org;
    }

    /**
     * Set associated Org
     * @param orgIn org to associate to specified slave
     */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }

    /**
     * Get slave specified by this entry
     * @return the salve
     */
    public IssSlave getSlave() {
        return slave;
    }

    /**
     * Set the slave specified by this entry
     * @param slaveIn specified slave
     */
    public void setSlave(IssSlave slaveIn) {
        this.slave = slaveIn;
    }

}
