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
import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.domain.org.Org;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.util.Date;
import java.util.SortedSet;

/**
 * ConfigChannel - Class representation of the table rhnConfigChannel.
 * @version $Rev$
 */
public class ConfigChannel extends BaseDomainHelper implements Identifiable {

    private Long id;
    private Org org;
    private String name;
    private String label;
    private String description;

    private ConfigChannelType configChannelType;
    
    private SortedSet configFiles;
    
    /**
     * Protected constructor
     * Use ConfigurationFactory to create a new channel.
     */
    protected ConfigChannel() {
        
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
     * Getter for orgId 
     * @return Long to get
    */
    public Long getOrgId() {
        return this.org.getId();
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
     * @return Returns the configChannelType.
     */
    public ConfigChannelType getConfigChannelType() {
        return configChannelType;
    }
    
    /**
     * @param configChannelTypeIn The configChannelType to set.
     */
    public void setConfigChannelType(ConfigChannelType configChannelTypeIn) {
        this.configChannelType = configChannelTypeIn;
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
        org = orgIn;
    }
    
    // Utility routines for common use cases
    
    /**
     * Is this a local (i.e. system) channel?
     * @return true if local
     */
    public boolean isLocalChannel() {
        return ConfigChannelType.local().equals(
                getConfigChannelType());
    }
    
    /**
     * Is this a global channel?
     * @return true if global
     */
    public boolean isGlobalChannel() {
        return ConfigChannelType.global().equals(
                getConfigChannelType());
    }
    
    /**
     * Is this a sandbox channel?
     * @return true if sandbox
     */
    public boolean isSandboxChannel() {
        return ConfigChannelType.sandbox().equals(
                getConfigChannelType());
    }

    /**
     * @return Returns the set of config files associated to this channel.
     */
    
    public SortedSet<ConfigFile> getConfigFiles() {
        return configFiles;
    }

    /** 
     * Setter for list of config files associated to this channel 
     * @param cfg to set
    */
    protected void setConfigFiles(SortedSet cfg) {
        this.configFiles = cfg;
    }

    
    /**
     * Provide a wrapper that returns a useful, I18N'd, name for a channel - 
     * relies on the utility function in ConfigurationFactory.
     * 
     * @return displayable, I18N'd channel name, even for local and sandbox channels
     */
    public String getDisplayName() {
        String typeStr = getConfigChannelType().getLabel();
        return ConfigurationFactory.getChannelNameDisplay(typeStr, getName());
    }
    
    /**
     * Creates a configuration file and saves it to the database
     * with the given information. 
     * Note: users of the same org do not automatically have access to this file.
     * See rhn_config_channel.get_user_file_access
     * @param state The state of the file (dead or alive)
     * @param cfn The file's path
     * @return T        he newly created ConfigFile
     */
    public ConfigFile createConfigFile(ConfigFileState state, ConfigFileName cfn) {
         ConfigFile file = ConfigurationFactory.newConfigFile();
         file.setConfigChannel(this);
         file.setConfigFileState(state);
         file.setConfigFileName(cfn);
         file.setCreated(new Date());
         file.setModified(new Date());
         ConfigurationFactory.commit(file);
         return file;
    }
     
     /**
      * See createConfigFile(ConfigFileState, ConfigFileName).
      * @param state The state of the file (dead or alive)
      * @param path The path of the file
      * @return The newly created ConfigFile
      */
     public ConfigFile createConfigFile(ConfigFileState state, String path) {
         ConfigFileName cfn = ConfigurationFactory.lookupOrInsertConfigFileName(path);
         return createConfigFile(state, cfn);
     }
    
    /**
     * 
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        ConfigChannel that = (ConfigChannel) obj;
        return new EqualsBuilder().
                append(this.getLabel(), that.getLabel()).
                append(this.getOrg(), that.getOrg()).
                append(this.getName(), that.getName()).
                append(this.getConfigChannelType(), that.getConfigChannelType()).
                isEquals();
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public int hashCode() {
        // The id field has been intentionally ignored here
        // because for a new object the id can be null
        // The label, name, org_id, channel type uniquely identify a Channel
       HashCodeBuilder builder = new HashCodeBuilder();

       builder.append(this.getOrg());
       builder.append(this.getName());
       builder.append(this.getLabel());
       builder.append(this.getConfigChannelType());
   
       return builder.toHashCode();
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public String toString() {
        ToStringBuilder builder = new ToStringBuilder(this);
        builder.append("id", getId()).
                append("label", getLabel()).
                append("name", getName()).
                append("org", getOrg()).
                append("type", getConfigChannelType());
        return builder.toString();
    }
}
