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
 * ConfigFileDto - represents all the revisions of a configuration file
 * in a single channel.
 * @version $Rev$
 */
public class ConfigFileDto extends BaseDto {
    private Long id;
    private String path;
    private String configChannelName;
    private String configChannelLabel;
    private String configChannelType;
    private Long configChannelId;
    private Long latestConfigRevisionId;
    private Integer latestConfigRevision;
    private Long latestRevisionSize;
    private Long totalFileSize;
    private String type;
    private Integer systemCount;
    private Integer overrideCount;
    private Date modified;

    //These two are used if the file is from a local channel
    private String serverName;
    private Long serverId;



    /**
     * @return Returns the modified.
     */
    public Date getModified() {
        return modified;
    }





    /**
     * @param modifiedIn The modified to set.
     */
    public void setModified(Date modifiedIn) {
        modified = modifiedIn;
    }




    /**
     * @return Returns the serverId.
     */
    public Long getServerId() {
        return serverId;
    }




    /**
     * @param serverIdIn The serverId to set.
     */
    public void setServerId(Long serverIdIn) {
        serverId = serverIdIn;
    }




    /**
     * @return Returns the serverName.
     */
    public String getServerName() {
        return serverName;
    }




    /**
     * @param serverNameIn The serverName to set.
     */
    public void setServerName(String serverNameIn) {
        serverName = serverNameIn;
    }



    /**
     * @return Returns the overrideCount.
     */
    public Integer getOverrideCount() {
        return overrideCount;
    }



    /**
     * @param overrideCountIn The overrideCount to set.
     */
    public void setOverrideCount(Integer overrideCountIn) {
        overrideCount = overrideCountIn;
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
     * @return Returns the type.
     */
    public String getType() {
        return type;
    }


    /**
     * @param typeIn The type to set.
     */
    public void setType(String typeIn) {
        type = typeIn;
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
     * @return Returns the configChannelLabel.
     */
    public String getConfigChannelLabel() {
        return configChannelLabel;
    }

    /**
     * @param configChannelLabelIn The configChannelLabel to set.
     */
    public void setConfigChannelLabel(String configChannelLabelIn) {
        configChannelLabel = configChannelLabelIn;
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
     * @return Returns the latestConfigRevision.
     */
    public Integer getLatestConfigRevision() {
        return latestConfigRevision;
    }

    /**
     * @param latestConfigRevisionIn The latestConfigRevision to set.
     */
    public void setLatestConfigRevision(Integer latestConfigRevisionIn) {
        latestConfigRevision = latestConfigRevisionIn;
    }

    /**
     * @return Returns the latestConfigRevisionId.
     */
    public Long getLatestConfigRevisionId() {
        return latestConfigRevisionId;
    }

    /**
     * @param latestConfigRevisionIdIn The latestConfigRevisionId to set.
     */
    public void setLatestConfigRevisionId(Long latestConfigRevisionIdIn) {
        latestConfigRevisionId = latestConfigRevisionIdIn;
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
     * @return Returns the totalFileSize.
     */
    public Long getTotalFileSize() {
        return totalFileSize;
    }

    /**
     * @param totalFileSizeIn The totalFileSize to set.
     */
    public void setTotalFileSize(Long totalFileSizeIn) {
        totalFileSize = totalFileSizeIn;
    }

    /**
     * @return Returns a formatted and localized version of the total file size
     */
    public String getTotalFileSizeDisplay() {
        return StringUtil.displayFileSize(totalFileSize.longValue(), false);
    }

    /**
     * @return Returns a formatted and localized version of the difference between
     * the modified date and now.
     */
    public String getModifiedDisplay() {
        return StringUtil.categorizeTime(modified.getTime(), StringUtil.WEEKS_UNITS);
    }

    /**
     * @return A localized version of the channel name.
     */
    public String getChannelNameDisplay() {
        return ConfigurationFactory.getChannelNameDisplay(configChannelType,
                configChannelName);
    }

    /**
     * @return Returns the latestRevisionSize.
     */
    public Long getLatestRevisionSize() {
        return latestRevisionSize;
    }

    /**
     * @param latestRevisionSizeIn The latestRevisionSize to set.
     */
    public void setLatestRevisionSize(Long latestRevisionSizeIn) {
        latestRevisionSize = latestRevisionSizeIn;
    }

    /**
     * @return Returns a formatted and localized version of the latest revision size
     */
    public String getLatestRevisionSizeDisplay() {
        return StringUtil.displayFileSize(latestRevisionSize.longValue(), false);
    }

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
}
