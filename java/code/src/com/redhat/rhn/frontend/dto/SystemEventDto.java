/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import java.io.Serializable;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang.StringUtils;

import com.redhat.rhn.common.localization.LocalizationService;

/**
 * DTO for a com.redhat.rhn.frontend.action..systems.sdc.SystemHistoryAction
 * @version $Rev$
 */
public class SystemEventDto extends BaseDto implements Serializable {

    private static final long serialVersionUID = -3582329112428837249L;

    protected long id;
    private Date created;
    private Date pickedUp;
    private Date completed;
    protected String summary;
    protected String historyType;
    protected String historyTypeName;
    private String historyStatus;
    protected static final Map<String, String> ACTIONTYPES;
    private boolean historyVisible;

    static {
        ACTIONTYPES = new HashMap<String, String>();
        ACTIONTYPES.put("packages.refresh_list", "event-type-package");
        ACTIONTYPES.put("packages.delta", "event-type-package");
        ACTIONTYPES.put("packages.update", "event-type-package");
        ACTIONTYPES.put("packages.remove", "event-type-package");
        ACTIONTYPES.put("packages.verify", "event-type-package");
        ACTIONTYPES.put("packages.runTransaction", "event-type-package");
        ACTIONTYPES.put("rollback.listTransactions", "event-type-package");
        ACTIONTYPES.put("up2date_config.get", "event-type-preferences");
        ACTIONTYPES.put("up2date_config.update", "event-type-preferences");
        ACTIONTYPES.put("rollback.config", "event-type-preferences");
        ACTIONTYPES.put("errata.update", "event-type-errata");
        ACTIONTYPES.put("hardware.refresh_list", "event-type-system");
        ACTIONTYPES.put("reboot.reboot", "event-type-system");
        ACTIONTYPES.put("configfiles.upload", "event-type-system");
        ACTIONTYPES.put("configfiles.deploy", "event-type-system");
        ACTIONTYPES.put("configfiles.verify", "event-type-system");
        ACTIONTYPES.put("configfiles.diff", "event-type-system");
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
        this.id = idIn;
    }

    /**
     * @return Returns date of creation
     */
    public Date getCreated() {
        return created;
    }

    /**
     * @param createdIn Date of creation to set
     */
    public void setCreated(String createdIn) {
        if (createdIn == null) {
            this.created = null;
        }
        else {
            try {
                this.created = new SimpleDateFormat(
                        LocalizationService.RHN_DB_DATEFORMAT).parse(createdIn);
            }
            catch (ParseException e) {
                throw new IllegalArgumentException("lastCheckin must be of the: [" +
                        LocalizationService.RHN_DB_DATEFORMAT + "] it was: " +
                        createdIn);
            }
        }
    }

    /**
     * @return Returns date of picking up of the event
     */
    public Date getPickedUp() {
        return pickedUp;
    }

    /**
     * @param pickedUpIn Date of pick up of event to set
     */
    public void setPickedUp(String pickedUpIn) {
        if (pickedUpIn == null) {
            this.pickedUp = null;
        }
        else {
            try {
                this.pickedUp = new SimpleDateFormat(
                        LocalizationService.RHN_DB_DATEFORMAT).parse(pickedUpIn);
            }
            catch (ParseException e) {
                throw new IllegalArgumentException("lastCheckin must be of the: [" +
                        LocalizationService.RHN_DB_DATEFORMAT + "] it was: " +
                        pickedUpIn);
            }
        }
    }

    /**
     * @return Date of completion of the event
     */
    public Date getCompleted() {
        return completed;
    }

    /**
     * @param completedIn Date of completion to set
     */
    public void setCompleted(String completedIn) {
        if (completedIn == null) {
            this.completed = null;
        }
        else {
            try {
                this.completed = new SimpleDateFormat(
                        LocalizationService.RHN_DB_DATEFORMAT).parse(completedIn);
            }
            catch (ParseException e) {
                throw new IllegalArgumentException("lastCheckin must be of the: [" +
                        LocalizationService.RHN_DB_DATEFORMAT + "] it was: " +
                        completedIn);
            }
        }
    }

    /**
     * @return Returns event summary
     */
    public String getSummary() {
        return summary;
    }

    /**
     * @param summaryIn Summary of event
     */
    public void setSummary(String summaryIn) {
        this.summary = summaryIn;
    }

    /**
     * @return Returns type of history event
     */
    public String getHistoryType() {
        if (ACTIONTYPES.containsKey(historyType)) {
            return ACTIONTYPES.get(historyType);
        }
        return historyType;
    }

    /**
     * @param historyTypeIn Type of history event
     */
    public void setHistoryType(String historyTypeIn) {
        this.historyType = historyTypeIn;
    }

    /**
     * @return History type event description
     */
    public String getHistoryTypeName() {
        return historyTypeName;
    }

    /**
     * @param historyTypeNameIn History event description to set
     */
    public void setHistoryTypeName(String historyTypeNameIn) {
        this.historyTypeName = historyTypeNameIn;
    }

    /**
     * @return Returns history event status
     */
    public String getHistoryStatus() {
        return StringUtils.isEmpty(historyStatus) ? "(n/a)" : historyStatus;
    }

    /**
     * @param historyStatusIn History status to set
     */
    public void setHistoryStatus(String historyStatusIn) {
        this.historyStatus = historyStatusIn;
    }

    /**
     * @return if details of this event will be visible
     */
    public boolean isHistoryVisible() {
        return historyVisible;
    }

    /**
     * @param historyVisibleIn to set if details of this event will be visible
     */
    public void setHistoryVisible(boolean historyVisibleIn) {
        this.historyVisible = historyVisibleIn;
    }

}
