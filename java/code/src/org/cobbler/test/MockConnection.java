/**
 * Copyright (c) 2008 Red Hat, Inc.
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

package org.cobbler.test;

import com.redhat.rhn.testing.TestUtils;

import org.cobbler.CobblerConnection;

import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;


/**
 * @author paji
 * @version $Rev$
 */
public class MockConnection extends CobblerConnection {
    private String token;
    
    /**
     * Mock constructors for Cobbler connection
     * Don't care..
     * @param urlIn whatever url
     * @param userIn user
     * @param passIn password
     */
    public MockConnection(String urlIn, 
            String userIn, String passIn) {
        super();
    }

    /**
     * Mock constructors for Cobbler connection
     * Don't care..
     * @param urlIn whatever url
     * @param tokenIn session token.
     */
    public MockConnection(String urlIn, String tokenIn) {
        super();
        token = tokenIn;
    }
    
    /**
     * {@inheritDoc}
     *      
     */
    @Override
    public Object invokeMethod(String name, Object... args) {
        //no op -> mock version .. 
        // we'll add more useful constructs in the future..
        System.out.println("called: " + name + " args: " + args);
        Object retval = null;
        
        if ("get_distros".equals(name) || "get_profiles".equals(name)) {
            Map row = new HashMap();
            row.put("name", TestUtils.randomString());
            retval = new LinkedList();
            ((LinkedList) retval).add(row);
        }
        else if ("get_distro".equals(name) || "get_profile".equals(name)) {
            retval = new HashMap();
            ((Map) retval).put("name", TestUtils.randomString());
        }
        System.out.println("retval: " + retval);
        return retval;
    }
    
    /**
     * {@inheritDoc}
     */
    public Object invokeTokenMethod(String procedureName, 
                                    Object... args) {
        List<Object> params = new LinkedList<Object>(Arrays.asList(args));
        params.add(token);
        return invokeMethod(procedureName, params);
    }
    
    /**
     * updates the token
     * @param tokenIn the cobbler auth token
     */
    public void setToken(String tokenIn) {
        token = tokenIn;
    }    
}
