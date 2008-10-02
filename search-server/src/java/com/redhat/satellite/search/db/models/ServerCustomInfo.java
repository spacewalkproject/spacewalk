/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.satellite.search.db.models;


/**
 * ServerCustomInfo
 * @version $Rev$
 */
public class ServerCustomInfo extends GenericRecord {
    private long id;
    private long serverId;
    private String value;
    private long createdBy;
    private long lastModifiedBy;
    private String created;
    private String modified;
    /**
     * @return the id
     */
    public long getId() {
        return id;
    }
    /**
     * @param idIn the id to set
     */
    public void setId(long idIn) {
        this.id = idIn;
    }
    /**
     * @return the serverId
     */
    public long getServerId() {
        return serverId;
    }
    /**
     * @param serverIdIn the serverId to set
     */
    public void setServerId(long serverIdIn) {
        this.serverId = serverIdIn;
    }
    /**
     * @return the created
     */
    public String getCreated() {
        return created;
    }
    /**
     * @param createdIn the created to set
     */
    public void setCreated(String createdIn) {
        this.created = createdIn;
    }
    /**
     * @return the modified
     */
    public String getModified() {
        return modified;
    }
    /**
     * @param modifiedIn the modified to set
     */
    public void setModified(String modifiedIn) {
        this.modified = modifiedIn;
    }
    /**
     * @return the value
     */
    public String getValue() {
        return value;
    }
    /**
     * @param valueIn the value to set
     */
    public void setValue(String valueIn) {
        this.value = valueIn;
    }
    /**
     * @return the createdBy
     */
    public long getCreatedBy() {
        return createdBy;
    }
    /**
     * @param createdByIn the createdBy to set
     */
    public void setCreatedBy(long createdByIn) {
        this.createdBy = createdByIn;
    }
    /**
     * @return the lastModifiedBy
     */
    public long getLastModifiedBy() {
        return lastModifiedBy;
    }
    /**
     * @param lastModifiedByIn the lastModifiedBy to set
     */
    public void setLastModifiedBy(long lastModifiedByIn) {
        this.lastModifiedBy = lastModifiedByIn;
    }

}
