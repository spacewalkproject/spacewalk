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

package com.redhat.rhn.domain.user.legacy;

import com.redhat.rhn.domain.BaseDomainHelper;

/**
 * Class that contains webUserId field to be used by children of the User object
 * (parent key)
 * @version $Rev: 76633 $
 */
public abstract class AbstractUserChild extends BaseDomainHelper {
    private Long webUserId;

    /**
     * Gets the current value of id
     * @return long the current value
     */
    public Long getWebUserId() {
        return this.webUserId;
    }

    /**
     * Sets the value of id to new value
     * @param webUserIdIn New value for id
     */
    protected void setWebUserId(Long webUserIdIn) {
        this.webUserId = webUserIdIn;
    }
}
