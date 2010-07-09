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
package com.redhat.rhn.frontend.xmlrpc.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.session.SessionManager;

public class XmlRpcTestUtils {

    private XmlRpcTestUtils() { }

    /**
     * Util to getSessionKey for a user. This differs from AuthHandler.login in that it
     * doesn't authenticate the user or make sure that they are committed in the db.
     * @param user The user to create the session key for
     * @return A session key for a session containing the user passed in.
     */
    public static String getSessionKey(User user) {
        //Log in the user (handles authentication and active/disabled logic)

        String lifetime = Config.get().getString("session_database_lifetime");
        long duration = new Long(lifetime).longValue();

        //Create a new session with the user
        WebSession session = SessionManager.makeSession(user.getId(), duration);

        return session.getKey();
    }
}
