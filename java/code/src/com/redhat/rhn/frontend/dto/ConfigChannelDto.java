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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.config.ConfigFileCount;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;

import java.util.Date;

/**
 * ConfigChannelDto for transferring data about configuration channels
 * @version $Rev$
 */
public class ConfigChannelDto extends BaseDto {
    private Long id;
    private Long orgId;
    private String name;
    private String label;
    private String description;
    private Date created;
    private Date modified;
    private Integer fileCount;
    private Integer deployableFileCount;
    private Integer systemCount;
    private String type;
    private Integer position;
    private Integer filesOnlyCount;
    private Integer dirsOnlyCount;
    private Integer symlinksOnlyCount;

    //These three are when dealing with a single revision
    private Integer configRevision;
    private Long configRevisionId;
    private Long configFileId;
    private String configFileType;
    private Integer subscribed;
    private Integer canAccess;




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
    public Integer getConfigRevision() {
        return configRevision;
    }


    /**
     * @param configRevisionIn The configRevision to set.
     */
    public void setConfigRevision(Integer configRevisionIn) {
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
     * @return Returns the created.
     */
    public Date getCreated() {
        return created;
    }

    /**
     * @param createdIn The created to set.
     */
    public void setCreated(Date createdIn) {
        created = createdIn;
    }

    /**
     * @return Returns the description.
     */
    public String getDescription() {
        return description;
    }

    /**
     * @param descriptionIn The description to set.
     */
    public void setDescription(String descriptionIn) {
        description = descriptionIn;
    }

    /**
     * @return Returns the fileCount.
     */
    public Integer getFileCount() {
        if (fileCount == null) {
            int totalFiles = 0;
            if (filesOnlyCount != null) {
                totalFiles += filesOnlyCount.intValue();
            }

            if (dirsOnlyCount != null) {
                totalFiles += dirsOnlyCount.intValue();
            }

            if (symlinksOnlyCount != null) {
                totalFiles += symlinksOnlyCount.intValue();
            }
            fileCount = new Integer(totalFiles);
        }
        return fileCount;
    }


    /**
     * Makes a nice looking file counts message
     * @return the file description
     */
    public String getFileCountsMessage() {
        return getFilesAndDirsDisplayString();
    }

    /**
     * @param fileCountIn The fileCount to set.
     */
    public void setFileCount(Integer fileCountIn) {
        fileCount = fileCountIn;
    }

    /**
     * @return Returns the id.
     */
    @Override
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
     * @return Returns the label.
     */
    public String getLabel() {
        return label;
    }

    /**
     * @param labelIn The label to set.
     */
    public void setLabel(String labelIn) {
        label = labelIn;
    }

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
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }

    /**
     * @param nameIn The name to set.
     */
    public void setName(String nameIn) {
        name = nameIn;
    }

    /**
     * @return Returns the orgId.
     */
    public Long getOrgId() {
        return orgId;
    }

    /**
     * @param orgIdIn The orgId to set.
     */
    public void setOrgId(Long orgIdIn) {
        orgId = orgIdIn;
    }
    /**
     *
     * @return returns the localized system count
     */
    public String getSystemCountString() {
        LocalizationService service =  LocalizationService.getInstance();
        Integer count = getSystemCount();
        final Integer one = new Integer(1);
        if (one.equals(count)) {
            return service.getMessage("system.common.onesystem");
        }
        if (count == null) {
            count = new Integer(0);
        }
        return service.getMessage("system.common.numsystems",
                                        new Object[] {count});
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
     * @return a Localized and user-friendly display for the config channel type.
     */
    public String getTypeDisplay() {
        return LocalizationService.getInstance().getMessage("config_channel." + getType());
    }

    /**
     * @return A localized version of the channel name.
     */
    public String getNameDisplay() {
        return ConfigurationFactory.getChannelNameDisplay(type, name);
    }



    /**
     * @return Returns the deployableFileCount.
     */
    public Integer getDeployableFileCount() {
        return deployableFileCount;
    }




    /**
     * @param deployableFileCountIn The deployableFileCount to set.
     */
    public void setDeployableFileCount(Integer deployableFileCountIn) {
        deployableFileCount = deployableFileCountIn;
    }




    /**
     * @return Returns the position.
     */
    public Integer getPosition() {
        return position;
    }




    /**
     * @param positionIn The position to set.
     */
    public void setPosition(Integer positionIn) {
        position = positionIn;
    }


    /**
     * @return the dirsOnlyCount
     */
    public Integer getDirsOnlyCount() {
        return dirsOnlyCount;
    }



    /**
     * @param count the dirsOnlyCount to set
     */
    public void setDirsOnlyCount(Integer count) {
        this.dirsOnlyCount = count;
    }



    /**
     * @return the filesOnlyCount
     */
    public Integer getFilesOnlyCount() {
        return filesOnlyCount;
    }


    /**
     * @param count the filesOnlyCount to set
     */
    public void setFilesOnlyCount(Integer count) {
        this.filesOnlyCount = count;
    }

    /**
     * @return the symlinksOnlyCount
     */
    public Integer getSymlinksOnlyCount() {
        return symlinksOnlyCount;
    }

    /**
     * @param count the symlinksOnlyCount
     */
    public void setSymlinksOnlyCount(Integer count) {
        this.symlinksOnlyCount = count;
    }

    /**
     * Returns a i18ned string
     * holding info on the Number of Files &amp; Directories
     * this is used in Config Channel Subscriptions page
     * @return a i18n'ed string..
     *
     */
    public String getFilesAndDirsDisplayString() {
        int files = 0, dirs = 0, symlinks = 0;
        if (filesOnlyCount != null) {
            files = filesOnlyCount.intValue();
        }
        if (dirsOnlyCount != null) {
            dirs = dirsOnlyCount.intValue();
        }
        if (symlinksOnlyCount != null) {
            symlinks = symlinksOnlyCount.intValue();
        }
        ConfigFileCount count = ConfigFileCount.create(files, dirs, symlinks);
        return ConfigActionHelper.makeFileCountsMessage(count, null, false, false);
    }

    /**
     * @return the subscribed
     */
    public Integer getSubscribed() {
        return subscribed;
    }

    /**
     * @param val the subscribed to set
     */
    public void setSubscribed(Integer val) {
        this.subscribed = val;
    }

    /**
     * check to see the user can this channel.
     * @return true if the user can access this channel
     */
    public boolean getCanAccess() {
        return 1 == canAccess;
    }

    /**
     * check to see the user can this channel.
     * @param access true if the user can access this channel
     */
    public void setCanAccess(Integer access) {
        this.canAccess = access;
    }

}
