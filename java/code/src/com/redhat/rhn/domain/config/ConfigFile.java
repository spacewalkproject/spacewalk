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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.BaseDomainHelper;

/**
 * ConfigFile - Class representation of the table rhnConfigFile.
 * @version $Rev$
 */
public class ConfigFile extends BaseDomainHelper {

    private Long id;
    private ConfigChannel configChannel;
    private ConfigFileName configFileName;
    private ConfigFileState configFileState;
    private ConfigRevision latestConfigRevision;
    
    
    /**
     * Protected constructor
     * Use ConfigurationFactory to create a new file.
     */
    protected ConfigFile() {
        
    }
    
    /**
     * @return Returns the latestConfigRevision.
     */
    public ConfigRevision getLatestConfigRevision() {
        return latestConfigRevision;
    }

    
    /**
     * @param latestConfigRevisionIn The latestConfigRevision to set.
     */
    public void setLatestConfigRevision(ConfigRevision latestConfigRevisionIn) {
        latestConfigRevision = latestConfigRevisionIn;
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
     * @return Returns the configChannel.
     */
    public ConfigChannel getConfigChannel() {
        return configChannel;
    }
    /**
     * @param configChannelIn The configChannel to set.
     */
    public void setConfigChannel(ConfigChannel configChannelIn) {
        this.configChannel = configChannelIn;
    }
    /**
     * @return Returns the configFileName.
     */
    public ConfigFileName getConfigFileName() {
        return configFileName;
    }
    /**
     * @param configFileNameIn The configFileName to set.
     */
    public void setConfigFileName(ConfigFileName configFileNameIn) {
        this.configFileName = configFileNameIn;
    }

    /**
     * @return Returns the configFileState.
     */
    public ConfigFileState getConfigFileState() {
        return configFileState;
    }
    
    /**
     * @param configFileStateIn The configFileState to set.
     */
    public void setConfigFileState(ConfigFileState configFileStateIn) {
        this.configFileState = configFileStateIn;
    }

    /**
     * Returns the maximum possible config file size in Bytes
     * @return config file size in bytes
     */
    public static int getMaxFileSize() {
        return Config.get().getInt(ConfigDefaults.CONFIG_REVISION_MAX_SIZE,
                ConfigDefaults.DEFAULT_CONFIG_REVISION_MAX_SIZE);
    }
}
