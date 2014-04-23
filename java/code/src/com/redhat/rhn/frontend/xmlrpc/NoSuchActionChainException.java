/**
 * Copyright (c) 2014 SUSE
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
 * No such Action Chain exception.
 */
public class NoSuchActionChainException extends FaultException {
    // Error code for the Action Chain
    public static final int ERROR_CODE = 2710;

    // Error label for the exeption
    public static final String ERROR_LABEL = "noSuchActionChain";

    /**
     * Action Chain exception with AC label.
     *
     * @param actionChainLabel Action Chain label.
     */
    public NoSuchActionChainException(String actionChainLabel) {
        super(NoSuchActionChainException.ERROR_CODE,
              NoSuchActionChainException.ERROR_LABEL,
              LocalizationService.getInstance().
                      getMessage("api.action.nosuchactionchain",
                                 new Object[] {actionChainLabel}));
    }

    /**
     * Action Chain exception with AC label and cause.
     *
     * @param actionChainLabel Action Chain label.
     * @param cause the cause (which is saved for later retrieval by the
     * Throwable.getCause() method). (A null value is permitted, and indicates
     * that the cause is nonexistent or unknown.)
     */
    public NoSuchActionChainException(String actionChainLabel, Throwable cause) {
        super(NoSuchActionChainException.ERROR_CODE,
              NoSuchActionChainException.ERROR_LABEL,
              LocalizationService.getInstance().
                      getMessage("api.action.nosuchactionchain",
                                 new Object[] {actionChainLabel}), cause);
    }
}
