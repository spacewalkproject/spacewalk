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

package com.redhat.rhn.frontend.xmlrpc;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.localization.LocalizationService;

/**
 * Invalid Package Exception
 *
 * @version $Rev$
 */
public class MultipleBaseChannelException extends FaultException  {

    /**
     * Constructor
     * @param chan1 first channel
     * @param chan2 second channel
     */
    public MultipleBaseChannelException(String chan1, String chan2) {
        super(1203, "Multiple Base Channels Selected" , LocalizationService.getInstance().
                getMessage("api.channel.software.multiplebasechannel",
                        new Object [] {chan1, chan2}));
    }

    /**
     * Constructor
     * @param chan1 first channel
     * @param chan2 second channel
     * @param cause the cause
     */
    public MultipleBaseChannelException(String chan1, String chan2, Throwable cause) {
        super(1203, "multipleBaseChannelSelected" , LocalizationService.getInstance().
                getMessage("api.channel.software.multiplebasechannel",
                        new Object [] {chan1, chan2}), cause);
    }

}
