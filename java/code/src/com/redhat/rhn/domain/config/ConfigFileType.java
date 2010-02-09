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
package com.redhat.rhn.domain.config;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.io.Serializable;
import java.util.Map;
import java.util.TreeMap;

/** 
 * @author Hibernate CodeGenerator 
 * @version $Rev: 98107 $
 */
public class ConfigFileType implements Serializable {
    
    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 3816155923541633076L;

    /** identifier field */
    private long           id;

    /** persistent field */
    private String         label;

    /** persistent field */
    private String         name;

    /** persistent field */
    private java.util.Date created;

    /** persistent field */
    private java.util.Date modified;

    public static final String FILE = "file";
    public static final String DIR = "directory";
    public static final String SYMLINK = "symlink";
    private static final Map POSSIBLE_TYPES = new TreeMap(String.
                                                    CASE_INSENSITIVE_ORDER);

    /**
     * @return symlink config file type
     */
    public static ConfigFileType symlink() {
        return lookup(SYMLINK);
    }

    /**
     * 
     * @return dir config file type
     */
    public static ConfigFileType dir() {
        return lookup(DIR); 
    }
    
    /**
     * 
     * @return file config file type
     */
    public static ConfigFileType file() {
        return lookup(FILE); 
    }    
    
    /**
     * Given a file type label it returns the associated 
     * file type object
     * @param type the file type label
     * @return the file type associated to the label.
     */    
    public static ConfigFileType lookup(String type) {
        if (POSSIBLE_TYPES.isEmpty()) {
            ConfigFileType file = ConfigurationFactory.
                                    lookupConfigFileTypeByLabel(FILE);
            ConfigFileType dir = ConfigurationFactory.
                            lookupConfigFileTypeByLabel(DIR);
            ConfigFileType symlink = ConfigurationFactory.
                            lookupConfigFileTypeByLabel(SYMLINK);
            POSSIBLE_TYPES.put(DIR, dir);
            POSSIBLE_TYPES.put("dir", dir);
            POSSIBLE_TYPES.put("folder", dir);

            POSSIBLE_TYPES.put(FILE, file);

            POSSIBLE_TYPES.put(SYMLINK, symlink);
        }
        
        if (!POSSIBLE_TYPES.containsKey(type)) {
            String msg = "Invalid type [" + type + "] specified. " +
                            "Make sure you specify one of the following types " +
                            "in your expression " + POSSIBLE_TYPES.keySet();
            throw new IllegalArgumentException(msg);
        }
        return (ConfigFileType)POSSIBLE_TYPES.get(type);
    }
    
    /**
     * Ctor for Hibernate
     * @param inLabel label
     * @param inName  name
     * @param inCreated when created
     * @param inModified last modified
     */
    protected ConfigFileType(java.lang.String inLabel, java.lang.String inName,
            java.util.Date inCreated, java.util.Date inModified) {
        this.label = inLabel;
        this.name = inName;
        this.created = inCreated;
        this.modified = inModified;
    }

    /**
     * default ctor 
     */
    protected ConfigFileType() {
    }

    /**
     * Get DB id
     * @return db id
     */
    public long getId() {
        return this.id;
    }

    /**
     * Set the id column
     * @param inId new DB id
     */
    public void setId(long inId) {
        this.id = inId;
    }

    /**
     * Get the label
     * @return label 
     */
    public java.lang.String getLabel() {
        return this.label;
    }

    /**
     * Set the label
     * @param inLabel new label
     */
    public void setLabel(java.lang.String inLabel) {
        this.label = inLabel;
    }

    /**
     * Get the name
     * @return name
     */
    public java.lang.String getName() {
        return this.name;
    }

    /**
     * Set the name
     * @param inName new name
     */
    public void setName(java.lang.String inName) {
        this.name = inName;
    }

    /**
     * Get the created date
     * @return Date of creation (~4800 BCE, I think)
     */
    public java.util.Date getCreated() {
        return this.created;
    }

    /**
     * Set creation date
     * @param inCreated new creation date
     */
    public void setCreated(java.util.Date inCreated) {
        this.created = inCreated;
    }

    /**
     * Get last modified date
     * @return time of last modification
     */
    public java.util.Date getModified() {
        return this.modified;
    }

    /**
     * Set date of last modification
     * @param inModified modification date
     */
    public void setModified(java.util.Date inModified) {
        this.modified = inModified;
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("id", getId()).toString();
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object other) {
        if (!(other instanceof ConfigFileType)) {
            return false;
        }
        ConfigFileType castOther = (ConfigFileType) other;
        return new EqualsBuilder().append(this.getId(), castOther.getId()).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getId()).toHashCode();
    }

}
