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

package org.cobbler.test;

import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.domain.server.test.NetworkInterfaceTest;

import org.apache.commons.lang.RandomStringUtils;
import org.apache.log4j.Logger;
import org.cobbler.CobblerConnection;

import java.util.ArrayList;
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
    private String url;

    private Logger log = Logger.getLogger(MockConnection.class);


    private static List<Map> profiles = new ArrayList<Map>();
    private static List<Map> distros = new ArrayList<Map>();
    private static List<Map> systems = new ArrayList<Map>();


    private static Map<String, Map> systemMap = new HashMap<String, Map>();
    private static Map<String, Map> profileMap = new HashMap<String, Map>();
    private static Map<String, Map> distroMap = new HashMap<String, Map>();


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
        url = urlIn;
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
        url = urlIn;
    }


    /**
     * Mock constructors for Cobbler connection
     * Don't care..
     * @param urlIn whatever url
     */
    public MockConnection(String urlIn) {
        super();
        url = urlIn;
    }


   public Object invokeMethod(String name, Object... args) {
    //no op -> mock version ..
    // we'll add more useful constructs in the future..
    // log.debug("called: " + name + " args: " + args);



    if ("token_check".equals(name) || "update".equals(name)) {
        return true;
    }
    if ("login".equals(name)) {
        return random();
    }

    if (name.startsWith("modify_") && "ksmeta".equals(args[1])) {
        args[1] = "ks_meta";
    }

    //profiles:
    if ("get_profiles".equals(name)) {
        return profiles;
    }
    else if ("find_profile".equals(name)) {
        return find((Map)args[0], profiles);
    }
    else if (name.equals("modify_profile")) {
        log.debug("PROFILE: Modify  w/ handle" + args[0] + ", set " + args[1] +
                "to " + args[2]);
        profileMap.get(args[0]).put(args[1], args[2]);
    }
    else if ("get_profile".equals(name)) {
        return findByName((String)args[0], profiles);
    }
    else if ("get_profile_handle".equals(name)) {
        String key = random();
        log.debug("PROFILE:  Got handle  w/ name " + args[0]);
        profileMap.put(key, findByName((String) args[0], profiles));
        return key;
    }
    else if ("remove_profile".equals(name)) {
        profiles.remove(findByName((String)args[0], profiles));
        return true;
    }
    else if ("new_profile".equals(name)) {
        HashMap profile = new HashMap();
        String uid = random();
        String key = random();
        profile.put("uid", uid);

        log.debug("PROFILE: Created w/ uid " + uid + "returing handle " + key);

        profiles.add(profile);
        profileMap.put(key, profile);

        profile.put("virt_bridge", "xenb0");
        profile.put("virt_cpus", Integer.valueOf(1));
        profile.put("virt_type", KickstartVirtualizationType.XEN_FULLYVIRT);
        profile.put("virt_path", "/tmp/foo");
        profile.put("virt_file_size", Integer.valueOf(8));
        profile.put("virt_ram", Integer.valueOf(512));
        profile.put("kernel_options", new HashMap());
        profile.put("kernel_options_post", new HashMap());
        profile.put("ks_meta", new HashMap());
        profile.put("redhat_management_key", "");
        return key;
    }
    //distros
    else if ("find_distro".equals(name)) {
        return find((Map)args[0], distros);
    }
    else if ("get_distros".equals(name)) {
        return distros;
    }
    else if (name.equals("modify_distro")) {
        log.debug("DISTRO: Modify  w/ handle" + args[0] + ", set " + args[1] +
                "to " + args[2]);
        distroMap.get(args[0]).put(args[1], args[2]);
    }
    else if ("get_distro".equals(name)) {
        return findByName((String)args[0], distros);
    }
    else if ("rename_distro".equals(name)) {
        log.debug("DISTRO: Rename w/ handle" + args[0]);
        distroMap.get(args[0]).put("name", args[2]);
        return "";
    }
    else if ("get_distro_handle".equals(name)) {
        log.debug("DISTRO:  Got handle  w/ name " + args[0]);
        String key = random();
        distroMap.put(key, findByName((String) args[0], distros));
        return key;
    }
    else if ("remove_distro".equals(name)) {
        distros.remove(findByName((String)args[0], distros));
        return true;
    }
    else if ("new_distro".equals(name)) {
        String uid = random();

        HashMap distro = new HashMap();
        String key = random();
        distro.put("uid", uid);

        log.debug("DISTRO: Created w/ uid " + uid + "returing handle " + key);

        distros.add(distro);
        distroMap.put(key, distro);

        distro.put("virt_bridge", "xenb0");
        distro.put("virt_cpus", Integer.valueOf(1));
        distro.put("virt_type", KickstartVirtualizationType.XEN_FULLYVIRT);
        distro.put("virt_path", "/tmp/foo");
        distro.put("virt_file_size", Integer.valueOf(8));
        distro.put("virt_ram", Integer.valueOf(512));
        distro.put("kernel_options", new HashMap());
        distro.put("kernel_options_post", new HashMap());
        distro.put("ks_meta", new HashMap());
        distro.put("redhat_management_key", "");
        return key;
    }
    //System
    else if ("find_system".equals(name)) {
        return find((Map)args[0], systems);
    }
    else if ("get_systems".equals(name)) {
        return systems;
    }
    else if (name.equals("modify_system")) {
        Map system = systemMap.get(args[0]);
        system.put(args[1], args[2]);
        systemMap.get(args[0]).put(args[1], args[2]);
    }
    else if ("get_system".equals(name)) {
        return findByName((String)args[0], systems);
    }
    else if ("get_system_handle".equals(name)) {
        if (findByName((String) args[0], systems) != null) {
            String key = random();
            systemMap.put(key, findByName((String) args[0], systems));
            return key;
        }
        return null;
    }
    else if ("remove_system".equals(name)) {
        systems.remove(findByName((String)args[0], systems));
    }
    else if ("new_system".equals(name)) {
        HashMap profile = new HashMap();
        String key = random();
        profile.put("uid", random());
        Map interfaces = new HashMap();
        Map iface = new HashMap();
        iface.put("mac_address", NetworkInterfaceTest.TEST_MAC);
        iface.put("ip_address", "127.0.0.1");
        interfaces.put("eth0", iface);
        profile.put("interfaces", interfaces);
        systems.add(profile);
        systemMap.put(key, profile);
        profile.put("ks_meta", new HashMap());
        profile.put("redhat_management_key", "");
        return key;
    }
    else {
        log.debug("Unhandled xmlrpc call in MockConnection: " + name);
    }
    return "";
   }

   private Map findByName(String name, List<Map> maps) {
       for (Map map : maps) {
           if (name.equals(map.get("name"))) {
               return map;
           }
       }
       return null;
   }


   private List<Map<String, Object>> find(Map <String, Object> criteria, List<Map> maps) {
       List<Map<String, Object>> ret = new LinkedList<Map<String, Object>>();
       for (Map map : maps) {
           int matched = 0;
           for (String key : criteria.keySet()) {
               if (!criteria.get(key).equals(map.get(key))) {
                   break;
               }
               matched++;
           }
           if (matched == criteria.size()) {
               ret.add(map);
           }
       }
       return ret;
   }

   private String random() {
       return RandomStringUtils.randomAlphabetic(10);
   }

    /**
     * {@inheritDoc}
     */
    public Object invokeTokenMethod(String procedureName,
                                    Object... args) {
        List<Object> params = new LinkedList<Object>(Arrays.asList(args));
        params.add(token);
        return invokeMethod(procedureName, params.toArray());
    }

    /**
     * updates the token
     * @param tokenIn the cobbler auth token
     */
    public void setToken(String tokenIn) {
        token = tokenIn;
    }

    /**
     * @return returns the cobbler url..
     */
    @Override
    public String getUrl() {
        return url + "/cobbler_api";
    }


    public static void clear() {
        profiles = new ArrayList<Map>();
        distros = new ArrayList<Map>();
        systems = new ArrayList<Map>();


        systemMap = new HashMap<String, Map>();
        profileMap = new HashMap<String, Map>();
        distroMap = new HashMap<String, Map>();
    }

}
