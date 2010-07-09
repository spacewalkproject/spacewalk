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
 * channel label.
 */
public class InvalidChannelLabelException extends FaultException {

    /**
     * Label the user attempted to give the channel.
     */
    private String label;

    /**
     * Indicates why the channel label is invalid.
     */
    private Reason reason;

    /**
     * Creates a new indication of a channel label issue that does not specify the reason
     * for the error.
     * <p/>
     * Ideally, this won't be used frequently. This was kept in to support current uses
     * that don't fit into the idea of validating if a label can be used in a channel
     * creation/edit.
     */
    public InvalidChannelLabelException() {
        super(1201, "invalidChannelLabel", "Invalid channel label");
    }

    /**
     * Creates a new indication that a given channel label is invalid
     *
     * @param labelIn  label the user attempted to give the channel
     * @param reasonIn flag indicating why the channel name is invalid; cannot be
     *                 <code>null</code>
     */
    public InvalidChannelLabelException(String labelIn, Reason reasonIn) {
        super(1201, "invalidChannelLabel", "Invalid channel label");

        this.label = labelIn;
        this.reason = reasonIn;
    }

    /**
     * Creates a new indication that a given channel label is invalid
     *
     * @param labelIn  label the user attempted to give the channel
     * @param reasonIn flag indicating why the channel name is invalid; cannot be
     *                 <code>null</code>
     * @param messageIdIn the string resource message ID
     * @param argIn an optional argument that is associated with messageId.  If there
     * is no argument, pass in an empty string.
     */
    public InvalidChannelLabelException(String labelIn, Reason reasonIn,
        String messageIdIn, String argIn) {

        super(1201, "invalidChannelLabel", messageIdIn, new Object[] {argIn});

        this.label = labelIn;
        this.reason = reasonIn;
    }

    /**
     * @return invalid label that caused this exception; may be <code>null</code>
     */
    public String getLabel() {
        return label;
    }

    /**
     * @return flag indicating what made the label returned from {@link #getLabel()}
     *         invalid; may be <code>null</code>
     */
    public Reason getReason() {
        return reason;
    }

    /**
     * Flags indicating the different reasons that may have caused a channel label to be
     * invalid.
     */
    public enum Reason {
        REGEX_FAILS,
        TOO_SHORT,
        IS_MISSING,
        LABEL_IN_USE,
        RHN_CHANNEL_BAD_PERMISSIONS
    }
}
