/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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

import com.redhat.rhn.common.localization.LocalizationService;

/**
 * DTO for a com.redhat.rhn.frontend.action..systems.sdc.SystemPendingEventsAction
 * @version $Rev$
 */
public class SystemPendingEventDto extends SystemEventDto implements Serializable {

    private static final long serialVersionUID = 1277838056019707817L;

    private Date scheduledFor;
    private Long prereqAid;
    private String actionName;
    private boolean selectable;

    /**
     * @return Returns date of creation
     */
    public Date getScheduledFor() {
        return scheduledFor;
    }

    /**
     * @param scheduledForIn Date of creation to set
     */
    public void setScheduledFor(String scheduledForIn) {
        if (scheduledForIn == null) {
            this.scheduledFor = null;
        }
        else {
            try {
                this.scheduledFor = new SimpleDateFormat(
                        LocalizationService.RHN_DB_DATEFORMAT).parse(scheduledForIn);
            }
            catch (ParseException e) {
                throw new IllegalArgumentException("lastCheckin must be of the: [" +
                        LocalizationService.RHN_DB_DATEFORMAT + "] it was: " +
                        scheduledForIn);
            }
        }
    }

    /**
     * @return Id of prerequisite action
     */
    public Long getPrereqAid() {
        return prereqAid;
    }

    /**
     * @param prereqAidIn prerequisite Id to set
     */
    public void setPrereqAid(Long prereqAidIn) {
        this.prereqAid = prereqAidIn;
    }

    /**
     * @return Action name
     */
    public String getActionName() {
        return actionName;
    }

    /**
     * @param actionNameIn action name to set
     */
    public void setActionName(String actionNameIn) {
        this.actionName = actionNameIn;
    }

    /**
    *
    * {@inheritDoc}
    */
   public String getSelectionKey() {
       return String.valueOf(getId());
   }

   /**
    * For compatibility reasons with PostgreSQL we accept also Integer.
    *
    * @param selectableIn Whether a server is selectable one if selectable,
    * null if not selectable
    */
   public void setSelectable(Integer selectableIn) {
       selectable = (selectableIn != null);
   }

   /**
    * @param selectableIn Whether a server is selectable one if selectable,
    * null if not selectable
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
   @Override
   public boolean isSelectable() {
       return selectable;
   }

}
