/**
 * Copyright (c) 2009--2018 Red Hat, Inc.
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
package com.redhat.rhn.manager.action;

import com.redhat.rhn.common.RhnRuntimeException;

/**
 * An exception thrown when a user attempts to cancel action which is in PICKED UP state.
 *
 * @version $Rev$
 */
public class ActionIsPickedUpException extends RhnRuntimeException {
    /**
     *
     */
    public ActionIsPickedUpException() {
    }

    /**
     * @param msg An error message
     */
    public ActionIsPickedUpException(String msg) {
        super(msg);
    }

    /**
     * @param t The Throwable to wrap
     */
    public ActionIsPickedUpException(Throwable t) {
        super(t);
    }

    /**
     * @param msg An error message
     * @param t The Throwable to wrap
     */
    public ActionIsPickedUpException(String msg, Throwable t) {
        super(msg, t);
    }
}
