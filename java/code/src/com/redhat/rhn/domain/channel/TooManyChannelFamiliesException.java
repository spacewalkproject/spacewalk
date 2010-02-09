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

/*
 * AUTOMATICALLY GENERATED FILE, DO NOT EDIT.
 */
package com.redhat.rhn.domain.channel;

import com.redhat.rhn.common.RhnRuntimeException;

/**
 * A channel may have only one channel family.
 * <p>

 *
 * @version definition($Rev: 76724 $)/template($Rev: 67725 $)
 */
public class TooManyChannelFamiliesException extends RhnRuntimeException  {

    private Long chanId;

    /////////////////////////
    // Constructors
    /////////////////////////
        /**
     * Constructor
     * @param channelId channel id
     * @param message exception message
     */
    public TooManyChannelFamiliesException(Long channelId, String message) {
        super(message);
        // begin member variable initialization
        this.chanId =  channelId;
    }

        /**
     * Constructor
     * @param channelId channel id
     * @param message exception message
     * @param cause the cause (which is saved for later retrieval
     * by the Throwable.getCause() method). (A null value is 
     * permitted, and indicates that the cause is nonexistent or 
     * unknown.)
     */
    public TooManyChannelFamiliesException(Long channelId, String message, 
            Throwable cause) {
        super(message, cause);
        // begin member variable initialization
        this.chanId =  channelId;
    }

    /////////////////////////
    // Getters/Setters
    /////////////////////////
    /**
     * Returns the value of channelId
     * @return Long channelId
     */
    public Long getChannelId() {
        return chanId;
    }

    /**
     * Sets the channelId to the given value.
     * @param channelId channel id
     */
    public void setChannelId(Long channelId) {
        this.chanId = channelId;
    }

}
