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
package com.redhat.rhn.domain.session;

import com.redhat.rhn.domain.user.User;

/**
 * An web session.
 * @version $Rev$
 */
public interface WebSession {

    /**
     * Gets the current value of id
     * @return long the current value
     */
    Long getId();

    /**
     * Gets the current value of web_user_id
     * @return long the current value
     */
    Long getWebUserId();

    /**
     * Sets the value of web_user_id to new value
     * @param idIn User id associated with this Session.
     */
    void setWebUserId(Long idIn);

    /**
     * Gets the current value of web_user_id
     * @return long the current value
     */
    User getUser();

    /**
     * Gets the current value of expires
     * @return long the current value
     */
    long getExpires();

    /**
     * Sets the value of expires to new value
     * @param expIn lifetime of this session in milliseconds.
     */
    void setExpires(long expIn);

    /**
     * Determine if the session is expired already
     * @return true if session has expired.
     */
    boolean isExpired();

    /**
     * Returns the value
     * @return the value
     */
    String getValue();

    /**
     * Makes a key for the session. This is a md5 hash of the id and the session secrets.
     * @return Returns the key for the session.
     */
    String getKey();
}
