/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.io.Serializable;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

/**
 * Simple DTO for transfering data from the DB to the UI through datasource.
 * 
 * @version $Rev: 1743 $
 */
public class SystemOverview extends BaseDto implements Serializable  {

    private Long id;
    private Long channelId;
    private Long securityErrata = 0L;
    private Long bugErrata = 0L;
    private Long enhancementErrata = 0L;
    private Long outdatedPackages;
    private Long configFilesWithDifferences;
    private String serverName;
    private Long serverAdmins;
    private Long groupCount;
    private Long noteCount;
    private Date modified;
    private String channelLabels;
    private Long historyCount;
    private Long lastCheckinDaysAgo;
    private Long pendingUpdates;
    private String info;
    private String nameOfUserWhoRegisteredSystem;
    private String os;
    private String release;
    private String serverArchName;
    private Date lastCheckin;
    private Date created;
    private Long locked;
    private String monitoringStatus;
    private String name;
    private List status;
    private List actionId;
    private boolean rhnSatellite;
    private boolean rhnProxy;
    private List entitlement;
    private List serverGroupTypeId;
    private List entitlementPermanent;
    private List entitlementIsBase;
    private boolean selectable;
    private String statusDisplay;
    private String lastCheckinString;
    private boolean isVirtualHost;
    private boolean isVirtualGuest;
    private static final  String NONE_VALUE = "(none)";
    
    
    /**
     * @return Returns the statusDisplay.
     */
    public String getStatusDisplay() {
        return statusDisplay;
    }
    /**
     * @param statusDisplayIn The statusDisplay to set.
     */
    public void setStatusDisplay(String statusDisplayIn) {
        this.statusDisplay = statusDisplayIn;
    }
    /**
     * @return Returns the isRhnProxy.
     */
    public boolean isRhnProxy() {
        return rhnProxy;
    }
    /**
     * @param serverId The server id, null if not a proxy
     */
    public void setIsRhnProxy(Long serverId) {
        this.rhnProxy = (serverId != null);
    }
    /**
     * @return Returns the isRhnSatellite.
     */
    public boolean isRhnSatellite() {
        return rhnSatellite;
    }
    /**
     * @param serverId The server id, null if not a satellite
     */
    public void setIsRhnSatellite(Long serverId) {
        this.rhnSatellite = (serverId != null);
    }
    /**
     * @return Returns the bugErrata.
     */
    public Long getBugErrata() {
        return bugErrata;
    }
    /**
     * @param bugErrataIn The bugErrata to set.
     */
    public void setBugErrata(Long bugErrataIn) {
        this.bugErrata = bugErrataIn;
    }
    /**
     * @return ReturnsIn the channelLabels.
     */
    public String getChannelLabels() {
        if (StringUtils.isBlank(channelLabels) ||  channelLabels.equals(NONE_VALUE)) {
            return LocalizationService.getInstance().getMessage("none.message");    
        }
        return channelLabels;
    }
    /**
     * @param channelLabelsIn The channelLabels to set.
     */
    public void setChannelLabels(String channelLabelsIn) {
        this.channelLabels = channelLabelsIn;
    }
    /**
     * @return Returns the enhancementErrata.
     */
    public Long getEnhancementErrata() {
        return enhancementErrata;
    }
    /**
     * @param enhancementErrataIn The enhancementErrata to set.
     */
    public void setEnhancementErrata(Long enhancementErrataIn) {
        this.enhancementErrata = enhancementErrataIn;
    }
    /**
     * @return Returns the groupCount.
     */
    public Long getGroupCount() {
        return groupCount;
    }
    /**
     * @param groupCountIn The groupCount to set.
     */
    public void setGroupCount(Long groupCountIn) {
        this.groupCount = groupCountIn;
    }
    /**
     * @return Returns the historyCount.
     */
    public Long getHistoryCount() {
        return historyCount;
    }
    /**
     * @param historyCountIn The historyCount to set.
     */
    public void setHistoryCount(Long historyCountIn) {
        this.historyCount = historyCountIn;
    }
    /** 
     * @return Returns the id for the base software channel.
     */
    public Long getChannelId() {
        return channelId;
    }
    /**
     * @param channelIdIn The base software channel id to set.
     */
    public void setChannelId(Long channelIdIn) {
        this.channelId = channelIdIn;
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
        this.id = idIn;
    }
    
    /**
     * @return Returns Date of the lastCheckin
     */
    public Date getLastCheckinDate() {
        return lastCheckin;
    }
    
    /**
     * @return Returns string that represents the lastCheckin time
     */
    public String getLastCheckinString() {
        return lastCheckinString;
    }
    
    /**
     * @param stringIn string to set the lastCheckinString to 
     */
    
    public void setLastCheckinString(String stringIn) {
        this.lastCheckinString = stringIn;
    }
    /**
     * @return Returns the lastCheckin.
     */
    public String getLastCheckin() {
        return LocalizationService.getInstance().formatDate(lastCheckin);
    }
    /**
     * @param lastCheckinIn The lastCheckin to set.
     */
    public void setLastCheckin(String lastCheckinIn) {
        if (lastCheckinIn == null) {
            this.lastCheckin = null;
        }
        else {
            try {
                this.lastCheckin = new SimpleDateFormat(
                        LocalizationService.RHN_DB_DATEFORMAT).parse(lastCheckinIn);
            }
            catch (ParseException e) {
                throw new IllegalArgumentException("lastCheckin must be of the: [" + 
                        LocalizationService.RHN_DB_DATEFORMAT + "] it was: " + 
                        lastCheckinIn);
            }
        }
    }

    /**
     * @return Returns the lastCheckinDaysAgo.
     */
    public Long getLastCheckinDaysAgo() {
        return lastCheckinDaysAgo;
    }
    /**
     * @param lastCheckinDaysAgoIn The lastCheckinDaysAgo to set.
     */
    public void setLastCheckinDaysAgo(Long lastCheckinDaysAgoIn) {
        this.lastCheckinDaysAgo = lastCheckinDaysAgoIn;
    }
    /**
     * @return Returns the locked.
     */
    public Long getLocked() {
        return locked;
    }
    /**
     * @param lockedIn The locked to set.
     */
    public void setLocked(Long lockedIn) {
        this.locked = lockedIn;
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
        this.modified = modifiedIn;
    }
    /**
     * @return Returns the noteCount.
     */
    public Long getNoteCount() {
        return noteCount;
    }
    /**
     * @param noteCountIn The noteCount to set.
     */
    public void setNoteCount(Long noteCountIn) {
        this.noteCount = noteCountIn;
    }
    /**
     * @return Returns the os.
     */
    public String getOs() {
        return os;
    }
    /**
     * @param osIn The os to set.
     */
    public void setOs(String osIn) {
        this.os = osIn;
    }
    /**
     * @return Returns the outdatedPackages.
     */
    public Long getOutdatedPackages() {
        return outdatedPackages;
    }
    /**
     * @param outdatedPackagesIn The outdatedPackages to set.
     */
    public void setOutdatedPackages(Long outdatedPackagesIn) {
        this.outdatedPackages = outdatedPackagesIn;
    }
    /**
     * @return Returns the configFilesWithDifferences.
     */
    public Long getConfigFilesWithDifferences() {
        return configFilesWithDifferences;
    }
    /**
     * @param configFilesWithDifferencesIn The configFilesWithDifferences to set.
     */
    public void setConfigFilesWithDifferences(Long configFilesWithDifferencesIn) {
        this.configFilesWithDifferences = configFilesWithDifferencesIn;
    }
    /**
     * @return Returns the pendingUpdates.
     */
    public Long getPendingUpdates() {
        return pendingUpdates;
    }
    /**
     * @param pendingUpdatesIn The pendingUpdates to set.
     */
    public void setPendingUpdates(Long pendingUpdatesIn) {
        this.pendingUpdates = pendingUpdatesIn;
    }
    /**
     * @return Returns the release.
     */
    public String getRelease() {
        return release;
    }
    /**
     * @param releaseIn The release to set.
     */
    public void setRelease(String releaseIn) {
        this.release = releaseIn;
    }
    /**
     * @return Returns the securityErrata.
     */
    public Long getSecurityErrata() {
        return securityErrata;
    }
    /**
     * @param securityErrataIn The securityErrata to set.
     */
    public void setSecurityErrata(Long securityErrataIn) {
        this.securityErrata = securityErrataIn;
    }
    /**
     * @return Returns the serverAdmins.
     */
    public Long getServerAdmins() {
        return serverAdmins;
    }
    /**
     * @param serverAdminsIn The serverAdmins to set.
     */
    public void setServerAdmins(Long serverAdminsIn) {
        this.serverAdmins = serverAdminsIn;
    }
    /**
     * @return Returns the serverArchName.
     */
    public String getServerArchName() {
        return serverArchName;
    }
    /**
     * @param serverArchNameIn The serverArchName to set.
     */
    public void setServerArchName(String serverArchNameIn) {
        this.serverArchName = serverArchNameIn;
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
        this.serverName = serverNameIn;
    }
    /**
     * @return Returns the monitoringStatus.
     */
    public String getMonitoringStatus() {
        return monitoringStatus;
    }
    /**
     * @param statIn The monitoringStatus to set.
     */
    public void setMonitoringStatus(String statIn) {
        this.monitoringStatus = statIn;
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
        this.name = nameIn;
    }
    /**
     * @return Returns the actionId.
     */
    public List getActionId() {
        return actionId;
    }
    /**
     * @param actionIdIn The actionId to set.
     */
    public void setActionId(List actionIdIn) {
        this.actionId = actionIdIn;
    }
    /**
     * @return Returns the status.
     */
    public List getStatus() {
        return status;
    }
    /**
     * @param statusIn The status to set.
     */
    public void setStatus(List statusIn) {
        this.status = statusIn;
    }
    /**
     * Returns the most applicable status with its action id
     * Completed supercedes Picked Up which supercedes Queued which supercedes Failed
     * @return An array with the first index as status and second index as actionId
     */
    public Object[] getCurrentStatusAndActionId() {
        Object[] results = new Object[2];
        if (status == null) {
            results[0] = null;
            results[1] = null;
        }
        else if (status.contains("Completed")) {
            results[0] = status.get(status.indexOf("Completed"));
            results[1] = actionId.get(status.indexOf("Completed"));
        }
        else if (status.contains("Picked Up")) {
            results[0] = status.get(status.indexOf("Picked Up"));
            results[1] = actionId.get(status.indexOf("Picked Up"));
        }
        else if (status.contains("Queued")) {
            results[0] = status.get(status.indexOf("Queued"));
            results[1] = actionId.get(status.indexOf("Queued"));
        }
        else {
            results[0] = status.get(status.indexOf("Failed"));
            results[1] = actionId.get(status.indexOf("Failed"));
        }
        return results;
    }
    
    /**
     * This is now for display only - the data goes into entitlement
     *
     * @return Returns the entitlementLevel.
     */
    public String getEntitlementLevel() {
        // Get the entitlements for this row. If not null, loop through and get 
        // localized versions of the labels and make into a comma-delimited list
        LocalizationService ls = LocalizationService.getInstance();
        List ent = getEntitlement();
        if (ent != null) {
            Iterator i = ent.iterator();
            // Get the first entitlement
            StringBuffer retval = new StringBuffer();
            retval.append(ls.getMessage((String) i.next()));
            //Loop through and append the rest
            while (i.hasNext()) {
                retval.append(ls.getMessage("list delimiter") +
                        ls.getMessage((String) i.next()));
            }
            // Save the list as entitlementLevel
            return retval.toString();
        }
        else { //unentitled
            return ls.getMessage("unentitled");
        }
    }
    /**
     * Display only..  
     * @return Returns the base entitlement
     */
    public String getBaseEntitlementLevel() {
        // Get the entitlements for this row. If not null, loop through and get 
        // localized versions of the labels and make into a comma-delimited list
        LocalizationService ls = LocalizationService.getInstance();
        List ent = getEntitlement();
        if (ent != null && ent.size() > 0) {
            return ls.getMessage((String) ent.get(0));
        }
        return ls.getMessage("unentitled");
    }
    
    /**
     * Display only..  
     * @return Returns the add-on entitlements
     */
    public String getAddOnEntitlementLevel() {
        // Get the entitlements for this row. If not null, loop through and get 
        // localized versions of the labels and make into a comma-delimited list
        LocalizationService ls = LocalizationService.getInstance();
        List ent = getEntitlement();
        
        if (ent == null || ent.size() < 2) {
            return ls.getMessage("unentitled"); 
        }
        
        String msg = ls.getMessage((String) ent.get(1));
        
        for (int i = 2; i < ent.size(); i++) {
            msg = msg + 
                  ls.getMessage("list delimiter") + 
                  ls.getMessage((String) ent.get(i));
        }
        return msg;
    }    

    /**
     * @return Returns the entitlement.
     */
    public List getEntitlement() {
        return entitlement;
    }
    /**
     * @param entitlementIn The entitlement to set.
     */
    public void setEntitlement(List entitlementIn) {
        this.entitlement = entitlementIn;
    }

    /**
     * @return Returns the serverGroupTypeId.
     */
    public List getServerGroupTypeId() {
        return serverGroupTypeId;
    }
    /**
     * @param serverGroupTypeIdIn The serverGroupTypeId to set.
     */
    public void setServerGroupTypeId(List serverGroupTypeIdIn) {
        this.serverGroupTypeId = serverGroupTypeIdIn;
    }

    /**
     * @return Returns the entitlementPermanent.
     */
    public List getEntitlementPermanent() {
        return entitlementPermanent;
    }
    /**
     * @param entitlementPermanentIn The entitlementPermanent to set.
     */
    public void setEntitlementPermanent(List entitlementPermanentIn) {
        this.entitlementPermanent = entitlementPermanentIn;
    }

    /**
     * @return Returns the entitlementIsBase.
     */
    public List getEntitlementIsBase() {
        return entitlementIsBase;
    }
    /**
     * @param entitlementIsBaseIn The entitlementIsBase to set.
     */
    public void setEntitlementIsBase(List entitlementIsBaseIn) {
        this.entitlementIsBase = entitlementIsBaseIn;
    }
    
    /**
     * @param selectableIn Whether a server is selectable
     * one if selectable, null if not selectable
     */
    public void setSelectable(Long selectableIn) {
        selectable = (selectableIn != null);
    }
    
    /**
     * Tells whether a system is selectable for the SSM
     * All management and provisioning entitled servers are true
     * They are false otherwise
     * @return whether the current system is UI selectable
     */
    public boolean isSelectable() {
        return selectable;
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("id", id).append("serverName",
                serverName).toString();
    }
    
    /**
     * Creates a string to represent how long the system has been inactive.
     * The unit it is in depends on how many hours is has been inactive
     */
    public void setInactivityString() {
        
        LocalizationService ls = LocalizationService.getInstance();
        StringBuffer buffer = new StringBuffer();
        
        if (lastCheckinDaysAgo.compareTo(new Long(1)) < 0) {
            buffer.append(lastCheckinDaysAgo * new Long(24));
            ls.getMessage("filter-form.jspf.hours");
        }
        else if (lastCheckinDaysAgo.compareTo(new Long(7)) < 0) {
            buffer.append(lastCheckinDaysAgo.longValue());
            ls.getMessage("filter-form.jspf.days");
        }
        else if (lastCheckinDaysAgo.compareTo(new Long(7)) >= 0) {
            buffer.append(lastCheckinDaysAgo.longValue() / 7);
            ls.getMessage("filter-form.jspf.weeks");
        }
        
        lastCheckinString = buffer.toString();
    }
    
    /**
     * @return Returns the info.
     */
    public String getInfo() {
        return info;
    }
    /**
     * @param infoIn The info to set.
     */
    public void setInfo(String infoIn) {
        this.info = infoIn;
    }
    /**
     * @return Returns the nameOfUserWhoRegisteredSystem.
     */
    public String getNameOfUserWhoRegisteredSystem() {
        return nameOfUserWhoRegisteredSystem;
    }
    /**
     * @param nameOfUserWhoRegisteredSystemIn The nameOfUserWhoRegisteredSystem to set.
     */
    public void setNameOfUserWhoRegisteredSystem(
            String nameOfUserWhoRegisteredSystemIn) {
        this.nameOfUserWhoRegisteredSystem = nameOfUserWhoRegisteredSystemIn;
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
        this.created = createdIn;
    }

    /**
     * @return Returns a boolean, 1 if system is a virtual host, 0 if not
     */
    public boolean getVirtualHost() {
        return this.isVirtualHost;
    }

    /**
     * @return Returns a boolean, 1 if system is a virtual guest, 0 if not
     */
    public boolean getVirtualGuest() {
        return this.isVirtualGuest;
    }
  
    /**
     * @param host Value is true if the system is a virtual host, false if the 
     *  system is not a virtual host. Sets isVirtualHost to true or false.
     */
    public void setVirtualHost(Object host) {
        isVirtualHost = (host != null); 
    }

    /**
     * @param guest Value is true if the system is a virtual guest, false if the 
     * system is not a virtual guest. Sets isVirtualGuest to true or false.
     */
    public void setVirtualGuest(Object guest) {
        isVirtualGuest = (guest != null);
    }
    
    /**
     * @return Returns the totalErrataCount.
     */
    public Long getTotalErrataCount() {
        return enhancementErrata + securityErrata + bugErrata;
    }
    

}
