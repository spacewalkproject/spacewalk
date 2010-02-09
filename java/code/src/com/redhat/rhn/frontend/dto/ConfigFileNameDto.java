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
package com.redhat.rhn.frontend.dto;

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.config.ConfigurationFactory;

import java.util.Date;

/**
 * ConfigFileNameDto
 * @version $Rev$
 */
public class ConfigFileNameDto extends BaseDto {
    
    private Long id;
    private String path;
    private Integer systemCount;
    
    //when dealing with a single revision for this file name.
    private Long configRevisionId;
    private Long configRevision;
    private Long configFileId;
    private Long configChannelId;
    private Long localConfigFileId;
    private Long localConfigChannelId;
    private Long localRevisionId;
    private String localConfigFileType;
    private Long localRevision;
    private String configChannelName;
    private String configChannelLabel;
    private String configChannelType;
    private String configFileType;
    
    private Date lastModifiedDate;
    
    /**
     * @return Returns the configChannelType.
     */
    public String getConfigChannelType() {
        return configChannelType;
    }

    
    /**
     * @param configChannelTypeIn The configChannelType to set.
     */
    public void setConfigChannelType(String configChannelTypeIn) {
        configChannelType = configChannelTypeIn;
    }

    
    /**
     * @return Returns the configFileType.
     */
    public String getConfigFileType() {
        return configFileType;
    }

    
    /**
     * @param configFileTypeIn The configFileType to set.
     */
    public void setConfigFileType(String configFileTypeIn) {
        configFileType = configFileTypeIn;
    }

    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        id = idIn;
    }
    
    /**
     * @return Returns the path.
     */
    public String getPath() {
        return path;
    }
    
    /**
     * @param pathIn The path to set.
     */
    public void setPath(String pathIn) {
        path = pathIn;
    }
    
    /**
     * @return Returns the systemCount.
     */
    public Integer getSystemCount() {
        return systemCount;
    }
    
    /**
     * @param systemCountIn The systemCount to set.
     */
    public void setSystemCount(Integer systemCountIn) {
        systemCount = systemCountIn;
    }

    
    /**
     * @return Returns the configChannelId.
     */
    public Long getConfigChannelId() {
        return configChannelId;
    }

    
    /**
     * @param configChannelIdIn The configChannelId to set.
     */
    public void setConfigChannelId(Long configChannelIdIn) {
        configChannelId = configChannelIdIn;
    }

    
    /**
     * @return Returns the configChannelName.
     */
    public String getConfigChannelName() {
        return configChannelName;
    }

    
    /**
     * @param configChannelNameIn The configChannelName to set.
     */
    public void setConfigChannelName(String configChannelNameIn) {
        configChannelName = configChannelNameIn;
    }

    
    /**
     * @return Returns the configFileId.
     */
    public Long getConfigFileId() {
        return configFileId;
    }

    
    /**
     * @param configFileIdIn The configFileId to set.
     */
    public void setConfigFileId(Long configFileIdIn) {
        configFileId = configFileIdIn;
    }

    
    /**
     * @return Returns the configRevision.
     */
    public Long getConfigRevision() {
        return configRevision;
    }

    
    /**
     * @param configRevisionIn The configRevision to set.
     */
    public void setConfigRevision(Long configRevisionIn) {
        configRevision = configRevisionIn;
    }

    
    /**
     * @return Returns the configRevisionId.
     */
    public Long getConfigRevisionId() {
        return configRevisionId;
    }

    
    /**
     * @param configRevisionIdIn The configRevisionId to set.
     */
    public void setConfigRevisionId(Long configRevisionIdIn) {
        configRevisionId = configRevisionIdIn;
    }
    
    /**
     * @return A localized version of the channel name.
     */
    public String getChannelNameDisplay() {
        return ConfigurationFactory.getChannelNameDisplay(configChannelType,
                configChannelName);
    }


    
    /**
     * @return the localRevision
     */
    public Long getLocalRevision() {
        return localRevision;
    }


    
    /**
     * @param lr the localRevision to set
     */
    public void setLocalRevision(Long lr) {
        this.localRevision = lr;
    }


    
    /**
     * @return the lastModifiedDate
     */
    public Date getLastModifiedDate() {
        return lastModifiedDate;
    }


    
    /**
     * @param date the lastModifiedDate to set
     */
    public void setLastModifiedDate(Date date) {
        this.lastModifiedDate = date;
    }
    /**
     * 
     * @return the formatted version of the last modifed date
     */
    public String getLastModifiedDateString() {
        return StringUtil.categorizeTime(getLastModifiedDate().getTime(),
                                         StringUtil.YEARS_UNITS);
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public String getSelectionKey() {
        return String.valueOf(getConfigFileId());
    }
    
    
    /**
     * @return the localConfigChannelId
     */
    public Long getLocalConfigChannelId() {
        return localConfigChannelId;
    }

    /**
     * @param chanId the localConfigChannelId to set
     */
    public void setLocalConfigChannelId(Long chanId) {
        this.localConfigChannelId = chanId;
    }


    
    /**
     * @return the localRevisionId
     */
    public Long getLocalRevisionId() {
        return localRevisionId;
    }


    
    /**
     * @param val the localRevisionId to set
     */
    public void setLocalRevisionId(Long val) {
        this.localRevisionId = val;
    }


    
    /**
     * @return the localConfigFileType
     */
    public String getLocalConfigFileType() {
        return localConfigFileType;
    }


    
    /**
     * @param cfgFileType the localConfigFileType to set
     */
    public void setLocalConfigFileType(String cfgFileType) {
        this.localConfigFileType = cfgFileType;
    }


    
    /**
     * @return the localConfigFileId
     */
    public Long getLocalConfigFileId() {
        return localConfigFileId;
    }

    /**
     * @param cfgId the localConfigFileId to set
     */
    public void setLocalConfigFileId(Long cfgId) {
        this.localConfigFileId = cfgId;
    }


    
    /**
     * @return the configChannelLabel
     */
    public String getConfigChannelLabel() {
        return configChannelLabel;
    }


    
    /**
     * @param label the configChannelLabel to set
     */
    public void setConfigChannelLabel(String label) {
        this.configChannelLabel = label;
    }
}
