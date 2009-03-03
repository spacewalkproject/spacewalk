/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.integration.IntegrationService;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerCommand;
import com.redhat.rhn.testing.TestObjectStore;
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
    private String login;
    
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
        login  = userIn;

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
        // System.out.println("called: " + name + " args: " + args);
        Object retval = null;
        if (name.equals("get_distros") || name.equals("get_profiles")) {
            Map row = new HashMap();
            if (name.equals("get_profiles")) {
                row.put("name", TestObjectStore.get().getObject("profile_name"));
                row.put("uid", TestObjectStore.get().getObject("profile_uid"));

                String kname = (String) TestObjectStore.get().getObject("profile_name");
                KickstartData ks = KickstartFactory.lookupKickstartDataByLabel(kname);
                String type = "wizard";
                if (ks.isRawData()) {
                    type = "upload";
                }
                 row.put("kickstart",  CobblerCommand.makeCobblerFileName(type + "/" +ks.getLabel(), ks.getOrg()));
            }
            else {
                row.put("name", TestObjectStore.get().getObject("distro_name"));
                row.put("uid", TestObjectStore.get().getObject("distro_uid"));
            }
            row.put("virt_bridge", "xenb0");
            row.put("virt_cpus", Integer.valueOf(1));
            row.put("virt_type", KickstartVirtualizationType.XEN_FULLYVIRT);
            row.put("virt_path", "/tmp/foo");
            row.put("virt_file_size", Integer.valueOf(8));
            row.put("virt_ram", Integer.valueOf(512));
            row.put("kernel_options", new HashMap());
            row.put("kernel_options_post", new HashMap());
            row.put("ks_meta", new HashMap());




            retval = new LinkedList();
            ((LinkedList) retval).add(row);
        }
        else if (name.equals("modify_profile") && args[0].equals("name")) {
            TestObjectStore.get().putObject("profile_name", args[1]);
        }
        else if ("get_profile".equals(name)) {
            retval = new HashMap();
            ((Map) retval).put("name", TestUtils.randomString());
            ((Map) retval).put("uid", TestObjectStore.get().getObject("profile_uid"));
            ((Map) retval).put("ks_meta", new HashMap());
        }
        else if ("get_distro".equals(name)) {
            retval = new HashMap();
            ((Map) retval).put("name", TestObjectStore.get().getObject("distro_name"));
            ((Map) retval).put("uid", TestObjectStore.get().getObject("distro_uid"));
            ((Map) retval).put("ks_meta", new HashMap());
        }
        else if ("remove_distro".equals(name)) {
            return Boolean.TRUE;
        }
        // System.out.println("retval: " + retval);
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
