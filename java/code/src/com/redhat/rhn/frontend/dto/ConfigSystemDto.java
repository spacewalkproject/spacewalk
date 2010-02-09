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
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * 
 * ConfigSystemDto
 * @version $Rev$
 */
public class ConfigSystemDto extends BaseDto {
    
    private Long id;
    private String name;
    private Long channelId;
    private Integer configFileCount;
    private Integer localFileCount;
    private Integer configChannelCount;
    private Integer globalFileCount;
    private Integer overriddenCount;
    private Integer outrankedCount;
    private boolean capable;
    private boolean provisioning;
    private int results;
    private Integer errorCode;
    private boolean rhnTools;
    private Date modified;
    
    //when dealing with single revisions for systems
    private Integer configRevision;
    private Long configRevisionId;
    private Long configFileId;
    private Long configChannelId;
    private String configChannelType;
    private String configChannelName;
    
    //these three ints will be chosen from the following static integers
    private int rhncfg;
    private int rhncfgActions;
    private int rhncfgClient;
    
    public static final int INSTALLED = 0; 
    public static final int PENDING = 1;
    public static final int NEEDED = 2;
    
    /**
     * Parses the query-returned character into a discernable static integer.
     * @param queryRetval
     * @return the integer corresponding to the package status
     */
    private int decideStatus(String queryRetval) {
        if (queryRetval.equalsIgnoreCase("Y")) {
            return INSTALLED;
        }
        else if (queryRetval.equalsIgnoreCase("P")) {
            return PENDING;
        }
        else {
            return NEEDED;
        }
    }
    
    /**
     * @param rhncfgIn The rhncfg to set.
     */
    public void setRhncfg(String rhncfgIn) {
        rhncfg = decideStatus(rhncfgIn);
    }


    /**
     * @param rhncfgActionsIn The rhncfgActions to set.
     */
    public void setRhncfgActions(String rhncfgActionsIn) {
        rhncfgActions = decideStatus(rhncfgActionsIn);
    }

    
    /**
     * @param rhncfgClientIn The rhncfgClient to set.
     */
    public void setRhncfgClient(String rhncfgClientIn) {
        rhncfgClient = decideStatus(rhncfgClientIn);
    }
    
    
    /**
     * @return Returns the rhncfg.
     */
    public int getRhncfg() {
        return rhncfg;
    }

    
    /**
     * @return Returns the rhncfgActions.
     */
    public int getRhncfgActions() {
        return rhncfgActions;
    }

    
    /**
     * @return Returns the rhncfgClient.
     */
    public int getRhncfgClient() {
        return rhncfgClient;
    }




    
    /**
     * Whether the system is subscribed to an rhn-tools channel
     * @return Returns the rhnTools.
     */
    public boolean isRhnTools() {
        return rhnTools;
    }




    
    /**
     * @param rhnToolsIn The rhnTools to set.
     */
    public void setRhnTools(String rhnToolsIn) {
        if (rhnToolsIn.equalsIgnoreCase("Y")) {
            rhnTools = true;
        }
        else {
            rhnTools = false;
        }
    }




    /**
     * @return Returns the errorCode.
     */
    public Integer getErrorCode() {
        return errorCode;
    }



    
    /**
     * @param errorCodeIn The errorCode to set.
     */
    public void setErrorCode(Integer errorCodeIn) {
        errorCode = errorCodeIn;
    }



    /**
     * @return Returns the results.
     */
    public int getResults() {
        return results;
    }


    
    /**
     * @param resultsIn The results to set.
     */
    public void setResults(int resultsIn) {
        results = resultsIn;
    }


    /**
     * @return Returns the provisioning.
     */
    public boolean isProvisioning() {
        return provisioning;
    }

    
    /**
     * @param provisioningIn The provisioning to set. Y if true, N if false.
     */
    public void setProvisioning(String provisioningIn) {
        if (provisioningIn.equalsIgnoreCase("Y")) {
            provisioning = true;
        }
        else {
            provisioning = false;
        }
    }
    
    /**
     * @return Returns the capable.
     */
    public boolean isCapable() {
        return capable;
    }

    
    /**
     * @param capableIn The capable to set. Y if true, N if false.
     */
    public void setCapable(String capableIn) {
        if (capableIn.equalsIgnoreCase("Y")) {
            capable = true;
        }
        else {
            capable = false;
        }
    }

    /**
     * @return Returns the channelId.
     */
    public Long getChannelId() {
        return channelId;
    }
    
    /**
     * @param channelIdIn The channelId to set.
     */
    public void setChannelId(Long channelIdIn) {
        channelId = channelIdIn;
    }
    
    /**
     * @return Returns the configChannelCount.
     */
    public Integer getConfigChannelCount() {
        return configChannelCount;
    }
    
    /**
     * @param configChannelCountIn The configChannelCount to set.
     */
    public void setConfigChannelCount(Integer configChannelCountIn) {
        configChannelCount = configChannelCountIn;
    }
    
    /**
     * @return Returns the globalFileCount.
     */
    public Integer getGlobalFileCount() {
        return globalFileCount;
    }
    
    /**
     * @param globalFileCountIn The globalFileCount to set.
     */
    public void setGlobalFileCount(Integer globalFileCountIn) {
        globalFileCount = globalFileCountIn;
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
     * @return Returns the localFileCount.
     */
    public Integer getLocalFileCount() {
        return localFileCount;
    }
    
    /**
     * @param localFileCountIn The localFileCount to set.
     */
    public void setLocalFileCount(Integer localFileCountIn) {
        localFileCount = localFileCountIn;
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
     * @return Returns the overriddenCount.
     */
    public Integer getOverriddenCount() {
        return overriddenCount;
    }
    
    /**
     * @param overriddenCountIn The overriddenCount to set.
     */
    public void setOverriddenCount(Integer overriddenCountIn) {
        overriddenCount = overriddenCountIn;
    }
    
    /**
     * Gives a localized display explaining what is necessary
     * for this system to have the configuration management
     * client capabilities.  Used on the TargetSystems page
     * in configuration management.
     * @return A localized display for required actions in 
     * order for a system to become configuration enabled
     */
    public String getRequiredActionsDisplay() {
        if (capable) {
            return ""; //for those that have the egg but lost the chicken
        }
        LocalizationService ls = LocalizationService.getInstance();
        List actions = new ArrayList();
        displayHelper(actions, provisioning, ls, "addprovisioning");
        displayHelper(actions, rhnTools, ls, "subscribetools");
        displayHelper(actions, rhncfg != NEEDED, ls, "installcfg");
        displayHelper(actions, rhncfgActions != NEEDED, ls, "installcfgactions");
        displayHelper(actions, rhncfgClient != NEEDED, ls, "installcfgclient");
        
        /* make sure to check that there actually is a pending action somewhere.
         * if there system is in such a state that they don't have the capability, but
         * they have all the requirements for capability, then make sure that we 
         * don't tell them that configuration management is pending
         */
        if (actions.size() == 0 && (rhncfg == PENDING || 
                rhncfgActions == PENDING || rhncfgClient == PENDING)) {
            return ls.getMessage("targetsystems.jsp.pending");
        }
        return StringUtil.join("<br />", actions);
    }
    
    private void displayHelper(List list, boolean decider,
            LocalizationService ls, String resource) {
        if (!decider) {
            list.add(ls.getMessage("targetsystems.jsp." + resource));
        }
    }
    
    /**
     * Whether the actions to enable configuration management were a success for this
     * system.
     * @return Whether enabling was a success.
     */
    public boolean isSuccess() {
        if (errorCode == null || 
                errorCode.intValue() != ConfigurationManager.ENABLE_SUCCESS) {
            return false;
        }
        return true;
    }
    
    /**
     * @return A localized string for the error or success of 
     *         enabling configuration management.
     */
    public String getErrorDisplay() {
        if (errorCode == null) {
            return "";
        }
        LocalizationService ls = LocalizationService.getInstance();
        
        switch (errorCode.intValue()) {
            case ConfigurationManager.ENABLE_SUCCESS:
                return ls.getMessage("summary.jsp.noerror");
            case ConfigurationManager.ENABLE_ERROR_PROVISIONING:
                return ls.getMessage("summary.jsp.provision");
            case ConfigurationManager.ENABLE_ERROR_RHNTOOLS:
                return ls.getMessage("summary.jsp.rhntools");
            case ConfigurationManager.ENABLE_ERROR_PACKAGES:
                return ls.getMessage("summary.jsp.packages");
            case ConfigurationManager.ENABLE_NEED_ORG_ADMIN:
                return ls.getMessage("summary.jsp.orgadmin");
            default:
                return "";
        }
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean isSelectable() {
        return !capable;
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
     * @return Returns the configFileCount.
     */
    public Integer getConfigFileCount() {
        return configFileCount;
    }

    
    /**
     * @param configFileCountIn The configFileCount to set.
     */
    public void setConfigFileCount(Integer configFileCountIn) {
        configFileCount = configFileCountIn;
    }
    
    /**
     * @return A localized version of the channel name.
     */
    public String getChannelNameDisplay() {
        return ConfigurationFactory.getChannelNameDisplay(configChannelType,
                configChannelName);
    }

    /**
     * @return the number of files outranked by higher-priority channels 
     */
    public Integer getOutrankedCount() {
        return outrankedCount;
    }

    /**
     * Set the number of outranked files
     * @param oc # of outranked files
     */
    public void setOutrankedCount(Integer oc) {
        outrankedCount = oc;
    }

    /**
     * @return the date this system's server-channel mapping was modified
     */
    public Date getModified() {
        return modified;
    }

    /**
     * Set the modified-date for this system's server-config-channel mapping
     * @param d modified date
     */
    public void setModified(Date d) {
        modified = d;
    }

}
