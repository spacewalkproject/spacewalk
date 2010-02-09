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
package com.redhat.rhn.frontend.dto.monitoring;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.frontend.dto.BaseDto;

import java.sql.Timestamp;
import java.util.StringTokenizer;

/**
 * TimeSeriesData
 * @version $Rev: 50942 $
 */
public class StateChangeData extends BaseDto {
    private String oId; 
    private String data;
    private String htmlifiedData;
    private Long entryTime;
    
    /**
     * @return Returns the oId.
     */
    public String getOId() {
        return oId;
    }
    /**
     * @param id The oId to set.
     */
    public void setOId(String id) {
        oId = id;
    }
    
    /**
     * @return Returns the data.
     */
    public String getData() {
        return data;
    }
    /**
     * @param dataIn The data to set.
     */
    public void setData(String dataIn) {
        this.data = dataIn;
        this.htmlifiedData = StringUtil.htmlifyText(dataIn);
    }

    /**
     * @return Returns the entryTime.
     */
    public Long getEntryTime() {
        return entryTime;
    }
    /**
     * @param entryTimeIn The entryTime to set.
     */
    public void setEntryTime(Long entryTimeIn) {
        this.entryTime = entryTimeIn;
    }
    
    /**
     * Format the entryTime field into a Localized date string.
     * @return String version of the entryTime Date
     */
    public String getEntryDate() {
        // Since the entryTime is stored in UNIX time - Minutes
        // we have to multiple by 1000 to get millis and then 
        // can format it into a Java date 
        Timestamp ts = new Timestamp(entryTime.longValue() * 1000);
        return LocalizationService.getInstance().formatDate(ts);
    }
    
    /**
     * The Message is the latter half of the "DATA" field:
     * UNKNOWN Lost connection to the monitored host 
     *         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
     * @return Returns the message.
     */
    public String getMessage() {
        if (data == null) {
            return null;
        }
        String message = data.substring(data.indexOf(" ") + 1);
        return message;
    }
    
    /**
     * The htmlifiedMessage is the latter half of the "htmlified DATA" field:
     * @return Returns the htmlified message.
     */
    public String getHtmlifiedMessage() {
        if (htmlifiedData == null) {
                return null;
            }
            String message = htmlifiedData.substring(htmlifiedData.indexOf(" ") + 1);
            return message;
    }

    /**
     * The Message is the latter half of the "DATA" field:
     * UNKNOWN Lost connection to the monitored host 
     * ^^^^^^^
     * @return Returns the state.
     */
    public String getState() {
        if (data == null) {
            return null;
        }
        StringTokenizer st = new StringTokenizer(data, " ");
        return st.nextToken();
    }

    /** {@inheritDoc} */
    public Long getId() {
        return entryTime;
    }
}
