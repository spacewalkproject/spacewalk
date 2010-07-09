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

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * HistoryEvent
 * @version $Rev$
 */
public class HistoryEvent extends BaseDto {

    private Long id;
    private Date created;
    private Date pickedUp;
    private Date completed;
    private String summary;
    private String historyStatus;
    private String historyType;
    private String historyTypeName;
    private String details;

    /**
     * gets details of the event
     * @return details
     */
    public String getDetails() {
        return details;
    }

    /**
     * sets details of the event
     * @param detailsIn event details to set
     */
    public void setDetails(String detailsIn) {
        this.details = detailsIn;
    }
    /**
     * @return Returns the completed.
     */
    public Date getCompleted() {
        return completed;
    }
    /**
     * @param completedIn The completed to set.
     */
    public void setCompleted(Date completedIn) {
        this.completed = completedIn;
    }


    /**
     * sets the completed date based on a string format dateFormat
     * @param completedIn the date in a string format
     */
    public void setCompleted(String completedIn) {
        String dateFormat = "yyyy-MM-dd kk:mm:ss";
        SimpleDateFormat format = new SimpleDateFormat(dateFormat);

        try {
            this.completed = format.parse(completedIn);
        }
       catch (ParseException e) {
            System.out.println("Cannot parse " + completedIn +
                    " according to format " + dateFormat);
            e.printStackTrace();
       }
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
     * @return Returns the historyStatus.
     */
    public String getHistoryStatus() {
        return historyStatus;
    }
    /**
     * @param historyStatusIn The historyStatus to set.
     */
    public void setHistoryStatus(String historyStatusIn) {
        this.historyStatus = historyStatusIn;
    }
    /**
     * @return Returns the historyType.
     */
    public String getHistoryType() {
        return historyType;
    }
    /**
     * @param historyTypeIn The historyType to set.
     */
    public void setHistoryType(String historyTypeIn) {
        this.historyType = historyTypeIn;
    }
    /**
     * @return Returns the historyTypeName.
     */
    public String getHistoryTypeName() {
        return historyTypeName;
    }
    /**
     * @param historyTypeNameIn The historyTypeName to set.
     */
    public void setHistoryTypeName(String historyTypeNameIn) {
        this.historyTypeName = historyTypeNameIn;
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
     * @return Returns the pickedUp.
     */
    public Date getPickedUp() {
        return pickedUp;
    }
    /**
     * @param pickedUpIn The pickedUp to set.
     */
    public void setPickedUp(Date pickedUpIn) {
        this.pickedUp = pickedUpIn;
    }
    /**
     * @return Returns the summary.
     */
    public String getSummary() {
        return summary;
    }
    /**
     * @param summaryIn The summary to set.
     */
    public void setSummary(String summaryIn) {
        this.summary = summaryIn;
    }
}
