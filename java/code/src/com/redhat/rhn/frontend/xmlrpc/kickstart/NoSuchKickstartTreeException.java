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
package com.redhat.rhn.frontend.xmlrpc.kickstart;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.localization.LocalizationService;


/**
 * NoSuchKickstartTreeException
 * @version $Rev$
 */
public class NoSuchKickstartTreeException extends FaultException {

    /**
     * Constructor
     * @param treeLabel the kickstart tree label
     */
    public NoSuchKickstartTreeException(String treeLabel) {
        super(2752, "invalidKickstartTreeLabel" , LocalizationService.getInstance().
                getMessage("api.kickstart.nosuchkickstarttreelabel",
                        new Object [] {treeLabel}));
    }

}
