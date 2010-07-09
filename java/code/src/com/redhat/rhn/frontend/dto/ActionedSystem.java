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

import java.util.Date;

/**
 * Simple DTO for transfering data from the DB to the UI through datasource.
 *
 * @version $Rev: 1846 $
 */
public class ActionedSystem extends SystemOverview {

    private Date displayDate;
    private String baseChannel;
    private String message;

    /**
     * @return Returns the baseChannel.
     */
    public String getBaseChannel() {
        return baseChannel;
    }
    /**
     * @param baseChannelIn The baseChannel to set.
     */
    public void setBaseChannel(String baseChannelIn) {
        this.baseChannel = baseChannelIn;
    }

    /**
     * @return Returns the displayDate.
     */
    public String getDisplayDate() {
        return LocalizationService.getInstance().formatDate(displayDate);
    }

    /**
     * @return Returns the displayDate.
     */
    public Date getDate() {
        return displayDate;
    }

    /**
     * @param displayDateIn The displayDate to set.
     */
    public void setDisplayDate(Date displayDateIn) {
        this.displayDate = displayDateIn;
    }

    /**
     * @return Returns the message.
     */
    public String getMessage() {
        return message;
    }
    /**
     * @param messageIn The message to set.
     */
    public void setMessage(String messageIn) {
        this.message = messageIn;
    }

    /**
     * We need to override the selectable from system overview query/dto.
     * @return Whether or not this system is selectable, always true.
     */
    public boolean isSelectable() {
        return true;
    }
}
