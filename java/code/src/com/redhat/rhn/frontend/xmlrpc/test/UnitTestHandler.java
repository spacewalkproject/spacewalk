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

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;

import java.util.Hashtable;

/**
 * xmlrpc handler for the general up2date process
 * @xmlrpc.ignore
 * @version $Rev$
 */
public class UnitTestHandler extends BaseHandler {

    /**
     * Test returning a hashtable
     *
     * @return login hash
     * @exception Exception if an error occurs
     */
    public Hashtable login()
        throws Exception {

        Hashtable retHash = new Hashtable();

        retHash.put("X-RHN-Server-Id", "foo");
        retHash.put("X-RHN-Auth-User-Id", "foo");
        retHash.put("X-RHN-Auth", "foo");
        retHash.put("X-RHN-Auth-Server-Time", "foo");
        retHash.put("X-RHN-Auth-Expire-Offset", "foo");
        retHash.put("X-RHN-Auth-Channels", "foo");

        return retHash;
    }

    /**
     * Add two numbers together.
     */
    public Integer add(Integer a, Integer b)
        throws Exception {
        return new Integer(a.intValue() + b.intValue());
    }

    public String getUserLogin(User u) {
        return u.getLogin();
    }

    /**
     * Throw a fault exception
     */
    public void throwFault()
        throws Exception {
        throw new InvalidUserNameException();
    }
}
