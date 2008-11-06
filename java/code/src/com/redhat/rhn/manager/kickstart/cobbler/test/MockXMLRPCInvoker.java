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
package com.redhat.rhn.manager.kickstart.cobbler.test;

import com.redhat.rhn.frontend.xmlrpc.util.XMLRPCInvoker;
import com.redhat.rhn.testing.TestUtils;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Mock class for invoking xmlrpc
 * @author mmccune
 *
 */
public class MockXMLRPCInvoker implements XMLRPCInvoker {
    
    private Set methodsCalled = new HashSet();
    
    public Object invokeMethod(String procedureName, List args) {
        methodsCalled.add(procedureName);
        
        if (procedureName.equals("new_profile") ||
                procedureName.equals("new_distro")) {
            return new String("1");
        }
        else if (procedureName.equals("get_profile")) {
            Map retval = new HashMap();
            if (methodsCalled.contains("remove_profile")) {
                return retval;
            }
            else {
                retval.put("name", TestUtils.randomString());
                return retval;
            }
        }
        else if (procedureName.equals("get_distro")) {
            Map retval = new HashMap();
            if (methodsCalled.contains("remove_distro")) {
                return retval;
            }
            else {
                retval.put("name", TestUtils.randomString());
                return retval;
            }
        }
        else if (procedureName.equals("get_profile_handle")) {
            return TestUtils.randomString();
        }
        else if (procedureName.equals("get_distro_handle")) {
            return TestUtils.randomString();
        }
        else if (procedureName.equals("remove_distro")) {
            return new Boolean(true);
        }
        else if (procedureName.equals("login")) {
            return TestUtils.randomString();
        }
        return new Object();
    }

}
