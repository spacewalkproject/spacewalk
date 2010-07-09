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
package com.redhat.rhn.frontend.xmlrpc.user;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.NoSuchUserException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.manager.user.UserManager;

/**
 * XmlRpcUserHelper
 * @version $Rev$
 */
public class XmlRpcUserHelper {

    //private instance
    private static XmlRpcUserHelper helper = new XmlRpcUserHelper();

    //private constructor
    private XmlRpcUserHelper() {
    }

    /**
     * @return Returns the running instance of this helper class
     */
    public static XmlRpcUserHelper getInstance() {
        return helper;
    }

    /**
     * Helper method to lookup a target user to operate on.
     * @param loggedInUser The user looking up the other user
     * @param login The login of the user you're looking for
     * @return Returns the user corresponding to login
     * @throws FaultException A PermissionCheckFailureException is thrown
     * if the logged in user doesn't have access to the user or the login is invalid. A
     * NoSuchUserException is thrown if the loggedInUser has the correct credentials but
     * the user corresponding to login doesn't exist.
     */
    public User lookupTargetUser(User loggedInUser, String login)
        throws FaultException {
        try {
            User user = UserManager.lookupUser(loggedInUser, login);
            return user;
        }
        catch (PermissionException e) {
            throw new PermissionCheckFailureException();
        }
        catch (LookupException e) {
            throw new NoSuchUserException();
        }
    }
}
