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

import com.redhat.rhn.domain.BaseDomainHelper;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.util.Map;
import java.util.TreeMap;

/**
 * ConfigChannelType - Class representation of the table rhnConfigChannelType.
 * @version $Rev$
 */
public class ConfigChannelType extends BaseDomainHelper {

    private Long id;
    private String label;
    private String name;
    private Long priority;

    public static final String NORMAL = "normal";
    public static final String LOCAL = "local_override";
    public static final String SANDBOX = "server_import";
    
    private static final Map POSSIBLE_TYPES = new TreeMap(String.
                                                    CASE_INSENSITIVE_ORDER);
    /**
     * 
     * @return the sandbox channel type object
     */
    public static ConfigChannelType sandbox() {
        return lookup(SANDBOX);
    }

    /**
     * 
     * @return the local channel type object
     */
    public static ConfigChannelType local() {
        return lookup(LOCAL);
    }
    
    /**
     * 
     * @return the global channel type object
     */
    public static ConfigChannelType global() {
        return lookup(NORMAL);
    }    
    
    /**
     * Given a channel type label it returns the associated 
     * channel type
     * @param type the channel type label
     * @return the channel type associated to the type label.
     */
    public static ConfigChannelType lookup(String type) {
        if (POSSIBLE_TYPES.isEmpty()) {
            ConfigChannelType global = ConfigurationFactory.
                            lookupConfigChannelTypeByLabel(NORMAL);
            ConfigChannelType local = ConfigurationFactory.
                            lookupConfigChannelTypeByLabel(LOCAL);
            ConfigChannelType sandbox = ConfigurationFactory.
                            lookupConfigChannelTypeByLabel(SANDBOX);
            POSSIBLE_TYPES.put(NORMAL, global);
            POSSIBLE_TYPES.put("central", global);
            POSSIBLE_TYPES.put("global", global);
            
            
            POSSIBLE_TYPES.put("local", local);            
            POSSIBLE_TYPES.put(LOCAL, local);
    
            POSSIBLE_TYPES.put(SANDBOX, sandbox);
            POSSIBLE_TYPES.put("sandbox", sandbox);
        }

        if (!POSSIBLE_TYPES.containsKey(type)) {
            String msg = "Invalid type [" + type + "] specified. " +
            "Make sure you specify one of the following types " +
                "in your expression " + POSSIBLE_TYPES.keySet();
            throw new IllegalArgumentException(msg);
        }
        return (ConfigChannelType) POSSIBLE_TYPES.get(type);        
    }
    
    /**
     * protected constructor.
     * Use the ConfigurationFactory to get ConfigChannelTypes.
     */
    protected ConfigChannelType() {
        
    }

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
     * Getter for label 
     * @return String to get
    */
    public String getLabel() {
        return this.label;
    }

    /** 
     * Setter for label 
     * @param labelIn to set
    */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /** 
     * Getter for name 
     * @return String to get
    */
    public String getName() {
        return this.name;
    }

    /** 
     * Setter for name 
     * @param nameIn to set
    */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /** 
     * Getter for priority 
     * @return Long to get
    */
    public Long getPriority() {
        return this.priority;
    }

    /** 
     * Setter for priority 
     * @param priorityIn to set
    */
    public void setPriority(Long priorityIn) {
        this.priority = priorityIn;
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public boolean equals(Object arg) {
        ConfigChannelType that = (ConfigChannelType) arg;
        return new EqualsBuilder().
                append(this.getLabel(), that.getLabel()).
                append(this.getPriority(), that.getPriority()).
                isEquals();
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().
                    append(this.getLabel()).
                    append(this.getPriority()).
                    toHashCode();
    }
}
