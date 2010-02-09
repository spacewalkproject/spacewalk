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
package com.redhat.rhn.manager.user;

import com.redhat.rhn.common.RhnRuntimeException;
import com.redhat.rhn.domain.user.User;

/**
 * DeleteSatAdminException
 *
 * Exception thrown when we cannot delete a Satellite administrator. (presumably because
 * they are the last remaining)
 *
 * @version $Rev$
 */
public class DeleteSatAdminException extends RhnRuntimeException {

    private User targetUser;

    /**
     * Constructor
     *
     * @param targetUserIn User we could not delete.
     */
    public DeleteSatAdminException(User targetUserIn) {
        super();
        this.targetUser = targetUserIn;
    }

    /**
     * Return the target user we could not delete.
     *
     * @return target user
     */
    public User getTargetUser() {
        return targetUser;
    }

}
