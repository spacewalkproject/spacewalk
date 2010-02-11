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
package com.redhat.rhn.frontend.xmlrpc;

import com.redhat.rhn.FaultException;

/**
 * Exception indicating the user attempted to create/rename a channel with an invalid
 * channel name.
 */
public class InvalidChannelNameException extends FaultException {

    /**
     * Name the user attempted to give the channel.
     */
    private String name;
    
    /**
     * Indicates why the channel name is invalid. 
     */
    private Reason reason;

    /**
     * Creates a new indication of a channel name issue that does not specify the reason
     * for the error.
     * <p/> 
     * Ideally, this won't be used frequently. This was kept in to support current uses
     * that don't fit into the idea of validating if a name can be used in a channel
     * creation/edit. 
     */
    public InvalidChannelNameException() {
        super(1200, "invalidChannelName", "Invalid channel name");
    }
    
    /**
     * Creates a new indication that a given channel name is invalid.
     *  
     * @param nameIn   name the user attempted to give the channel
     * @param reasonIn flag indicating why the channel name is invalid; cannot be
     *                 <code>null</code>
     */
    public InvalidChannelNameException(String nameIn, Reason reasonIn) {
        super(1200, "invalidChannelName", "Invalid channel name");

        this.name = nameIn;
        this.reason = reasonIn;
    }

    /**
     * Creates a new indication that a given channel name is invalid.
     *
     * @param nameIn   name the user attempted to give the channel
     * @param reasonIn flag indicating why the channel name is invalid; cannot be
     *                 <code>null</code>
     * @param messageIdIn the string resource message ID
     * @param argIn an optional argument that is associated with messageId.  If there
     * is no argument, pass in an empty string.
     */
    public InvalidChannelNameException(String nameIn, Reason reasonIn,
        String messageIdIn, String argIn) {

        super(1200, "invalidChannelName", messageIdIn, new Object[] {argIn});

        this.name = nameIn;
        this.reason = reasonIn;
    }

    /**
     * @return invalid name that caused this exception; may be <code>null</code>
     */
    public String getName() {
        return name;
    }

    /**
     * @return flag indicating what made the name returned from {@link #getName()}
     *         invalid; may be <code>null</code>
     */
    public Reason getReason() {
        return reason;
    }

    /**
     * Flags indicating the different reasons that may have caused a channel name to be
     * invalid.
     */
    public enum Reason {
        REGEX_FAILS,
        TOO_SHORT,
        TOO_LONG,
        IS_MISSING,
        NAME_IN_USE,
        RHN_CHANNEL_BAD_PERMISSIONS
    }
}
