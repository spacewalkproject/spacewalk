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

package org.cobbler;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;


/**
 * @version $Rev$
 */

public class SystemRecord extends CobblerObject {
    
    private static final String PROFILE = "profile";
    private static final String VIRT_BRIDGE = "virt_bridge";
    private static final String VIRT_CPUS = "virt_cpus";
    private static final String VIRT_TYPE = "virt_type";
    private static final String VIRT_PATH = "virt_path";
    private static final String VIRT_FILE_SIZE = "virt_file_size";
    private static final String VIRT_RAM = "virt_ram";
    private static final String NETBOOT_ENABLED = "netboot_enabled";

    public static final String REDHAT_MGMT_SERVER = "redhat_management_server";

    private SystemRecord(CobblerConnection clientIn) {
        client = clientIn;
    }

    /**
     * Create a new system record in cobbler 
     * @param client the xmlrpc client
     * @param name the system record name
     * @return the newly created system record
     */
    public static SystemRecord create(CobblerConnection client, 
                                String name) {
        SystemRecord sys = new SystemRecord(client);
        sys.handle = (String) client.invokeTokenMethod("new_system");
        sys.modify(NAME, name);
        sys.save();
        sys = lookupByName(client, name);
        return sys;
    }

    /**
     * Returns a system record matching the given name or null
     * @param client the xmlrpc client
     * @param name the system name
     * @return the system that maps to the name or null
     */
    public static SystemRecord lookupByName(CobblerConnection client, String name) {
        return handleLookup(client, lookupDataMapByName(client, name, "get_system"));
    }

    /**
     *  Returns the system matching the given uid or null
     * @param client client the xmlrpc client  
     * @param id the uid of the system record
     * @return the system record matching the given uid or null
     */
    public static SystemRecord lookupById(CobblerConnection client, String id) {
        return handleLookup(client, lookupDataMapById(client, id, "find_system"));
    }    

    private static SystemRecord handleLookup(CobblerConnection client, Map sysMap) {
        if (sysMap != null) {
            SystemRecord sys = new SystemRecord(client);
            sys.dataMap = sysMap;
            return sys;
        }
        return null;
    }    
    
    /**
     * Returns a list of available systems 
     * @param connection the cobbler connection
     * @return a list of systems.
     */
    public static List<SystemRecord> list(CobblerConnection connection) {
        List <SystemRecord> systems = new LinkedList<SystemRecord>();
        List <Map<String, Object >> cSystems = (List <Map<String, Object >>) 
                                        connection.invokeMethod("get_systems");
        
        for (Map<String, Object> sysMap : cSystems) {
            SystemRecord sys = new SystemRecord(connection);
            sys.dataMap = sysMap;
            systems.add(sys);
        }
        return systems;
    }


    /**
     * Returns a list of available systems minus the excludes list
     * @param connection the cobbler connection
     * @param excludes a list of cobbler ids to file on 
     * @return a list of systems.
     */
    public static List<SystemRecord> list(CobblerConnection connection,
                                Set<String> excludes) {
        List <SystemRecord> systems = new LinkedList<SystemRecord>();
        List <Map<String, Object >> cSystems = (List <Map<String, Object >>) 
                                        connection.invokeMethod("get_systems");
        
        for (Map<String, Object> sysMap : cSystems) {
            SystemRecord sys = new SystemRecord(connection);
            sys.dataMap = sysMap;
            if (!excludes.contains(sys.getId())) {
                systems.add(sys);    
            }
        }
        return systems;
    }
    
    @Override
    protected String invokeGetHandle() {
        return (String)client.invokeTokenMethod("get_system_handle", this.getName());
    }
    
    @Override
    protected void invokeModify(String key, Object value) {
        client.invokeTokenMethod("modify_system", getHandle(), key, value);
    }
    
    /**
     * calls save_system to complete the commit
     */
    @Override
    protected void invokeSave() {
        client.invokeTokenMethod("save_system", getHandle());
    }

    /**
     * removes the kickstart system from cobbler.
     */
    @Override
    protected boolean invokeRemove() {
        return (Boolean) client.invokeTokenMethod("remove_system", getName());
    }
    
    /**
     * reloads the kickstart system.
     */
    @Override
    protected void reload() {
        SystemRecord newSystem = lookupById(client, getId());
        dataMap = newSystem.dataMap;
    }

    /* (non-Javadoc)
     * @see org.cobbler.CobblerObject#renameTo(java.lang.String)
     */

    @Override
    protected void invokeRename(String newNameIn) {
        client.invokeTokenMethod("rename_system", getHandle(), newNameIn);
    }    
    
    /**


     /**
     * @return the Cobbler Profile name
     */
     public String getProfile() {
         return (String)dataMap.get(PROFILE);
     }

     /**
     * @return the VirtBridge
     */
     public String getVirtBridge() {
         return (String)dataMap.get(VIRT_BRIDGE);
     }

     /**
     * @return the VirtCpus
     */
     public int getVirtCpus() {
         return (Integer)dataMap.get(VIRT_CPUS);
     }

     /**
     * @return the VirtType
     */
     public String getVirtType() {
         return (String)dataMap.get(VIRT_TYPE);
     }

     /**
     * @return the VirtPath
     */
     public String getVirtPath() {
         return (String)dataMap.get(VIRT_PATH);
     }

     /**
     * @return the VirtFileSize
     */
     public int getVirtFileSize() {
         return (Integer)dataMap.get(VIRT_FILE_SIZE);
     }

     /**
     * @return the VirtRam
     */
     public int getVirtRam() {
         return (Integer)dataMap.get(VIRT_RAM);
     }
     /**
      * true if netboot enabled is true
      * false other wise
      * @return netboot enabled value
      */
     public boolean isNetbootEnabled() {
         return Boolean.TRUE.toString().
             equalsIgnoreCase((String.valueOf(dataMap.get(NETBOOT_ENABLED))));
     }
 
      /**
      * @param virtBridgeIn the VirtBridge
      */
      public void setVirtBridge(String virtBridgeIn) {
          modify(VIRT_BRIDGE, virtBridgeIn);
      }

      /**
      * @param virtCpusIn the VirtCpus
      */
      public void setVirtCpus(int virtCpusIn) {
          modify(VIRT_CPUS, virtCpusIn);
      }

      /**
      * @param virtTypeIn the VirtType
      */
      public void setVirtType(String virtTypeIn) {
          modify(VIRT_TYPE, virtTypeIn);
      }

      /**
      * @param virtPathIn the VirtPath
      */
      public void setVirtPath(String virtPathIn) {
          modify(VIRT_PATH, virtPathIn);
      }

      /**
      * @param virtFileSizeIn the VirtFileSize
      */
      public void  setVirtFileSize(long virtFileSizeIn) {
          modify(VIRT_FILE_SIZE, virtFileSizeIn);
      }

      /**
      * @param virtRamIn the VirtRam
      */
      public void  setVirtRam(long virtRamIn) {
          modify(VIRT_RAM, virtRamIn);
      }

      /**
       * Enable netboot
       * @param enable true to enable net boot.
       */
      public void enableNetboot(boolean enable) {
          modify(NETBOOT_ENABLED, enable);
      }
}
