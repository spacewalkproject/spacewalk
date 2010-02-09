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

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * SolarisPatchSet
 * @version $Rev$
 */
public class SolarisPatchSet {
    private Long id;
    private String name;
    private Date setDate;
    private List timestamp;
    private List actionStatus;
    
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
     * @return Returns the setDate.
     */
    public String getSetDate() {
        return LocalizationService.getInstance().formatShortDate(setDate);
    }
    /**
     * @param setDateIn The setDate to set.
     */
    public void setSetDate(Date setDateIn) {
        this.setDate = setDateIn;
    }

    /**
     * @return Returns the actionStatuses list.
     */
    public List getActionStatus() {
        if (actionStatus == null) {
            actionStatus = new ArrayList(); 
        }
        return actionStatus;
    }
    /**
     * @param actionStatusIn The actionStatus list to set.
     */
    public void setActionStatus(List actionStatusIn) {
        actionStatus = actionStatusIn;
    }
    /**
     * @return Returns the timestamp list.
     */
    public List getTimestamp() {
        return timestamp;
    }
    /**
     * @param timestampIn The timestamp list to set.
     */
    public void setTimestamp(List timestampIn) {
        this.timestamp = timestampIn;
    }
    
    /**
     * Get the latest action timestamp for display - i.e., when was
     * the last time an action was attempted for this patch cluster.
     *
     * @return Returns the latest timestamp from the timestamp list as
     * a string, localized to the current Locale.
     */
    public String getLatestActionTimestamp() {
        if (timestamp == null) {
            timestamp = new ArrayList();
        }

        if (timestamp.isEmpty()) {
            return "(none)";
        }
        
        return LocalizationService.getInstance().formatDate((Date) timestamp.get(0));
    }
    
    /**
     * Get the latest action status for display - i.e., what is the
     * status of the last action attempted for this patch cluster.
     *
     * @return The actions status, as a string
     */
    public String getLatestActionStatus() {
        if (actionStatus == null) {
            actionStatus = new ArrayList();
        }
        
        if (actionStatus.isEmpty()) {
            return "(none)";
        }
        
        return actionStatus.get(0).toString();
    }
}

