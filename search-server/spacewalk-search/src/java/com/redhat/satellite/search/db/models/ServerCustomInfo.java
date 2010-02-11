/**
 * Copyright (c) 2008--2010 Red Hat, Inc.
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
    private long keyId;
    private long serverId;
    private String label;
    private String value;
    private long createdBy;
    private long lastModifiedBy;
    private String created;
    private String modified;

    /**
     *
     * @param serverIdIn server id
     * @param keyIdIn key id
     * @return string based on server id and key id
     */
    public static String makeUniqId(long serverIdIn, long keyIdIn) {
        return serverIdIn + "-" + keyIdIn;
    }

    /**
     *
     * @return uniqId
     */
    public String getUniqId() {
        return makeUniqId(serverId, keyId);
    }
    /**
     * @return the keyId
     */
    public long getKeyId() {
        return keyId;
    }
    /**
     * @param keyIdIn the keyId to set
     */
    public void setKeyId(long keyIdIn) {
        this.keyId = keyIdIn;
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
     * @return the label
     */
    public String getLabel() {
        return label;
    }
    /**
     * @param labelIn the label to set
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
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
