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

package org.cobbler;

import java.util.Date;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;


/**
 * @author paji
 * @version $Rev$
 */
public class Profile {
    private String handle;
    private Map<String, Object> dataMap = new HashMap<String, Object>();
    private CobblerConnection client;
    private static final String COMMENT = "comment";
    private static final String OWNERS = "owners";
    private static final String CTIME = "ctime";
    private static final String KERNEL_OPTIONS_POST = "kernel_options_post";
    private static final String DEPTH = "depth";
    private static final String KERNEL_OPTIONS = "kernel_options";
    private static final String NAME = "name";
    private static final String KS_META = "ks_meta";
    private static final String PARENT = "parent";
    private static final String MTIME = "mtime";
    private static final String MGMT_CLASSES = "mgmt_classes";
    private static final String TEMPLATE_FILES = "template_files";
    private static final String UID = "uid";

    private static final String DHCP_TAG = "dhcp_tag";
    private static final String KICKSTART = "kickstart";
    private static final String VIRT_BRIDGE = "virt_bridge";
    private static final String VIRT_CPUS = "virt_cpus";
    private static final String VIRT_TYPE = "virt_type";
    private static final String REPOS = "repos";
    private static final String VIRT_PATH = "virt_path";
    private static final String SERVER = "server";
    private static final String NAME_SERVERS = "name_servers";
    private static final String ENABLE_MENU = "enable_menu";
    private static final String VIRT_FILE_SIZE = "virt_file_size";
    private static final String VIRT_RAM = "virt_ram";
    private static final String DISTRO = "distro";    

    private Profile(CobblerConnection clientIn) {
        client = clientIn;
    }

    /**
     * Create a new kickstart profile in cobbler 
     * @param client the xmlrpc client
     * @param name the profile name
     * @param distro the distro allocated to this profile.
     * @return the newly created profile
     */
    public static Profile create(CobblerConnection client, 
                                String name, Distro distro) {
        Profile profile = new Profile(client);
        profile.handle = (String) client.invokeTokenMethod("new_profile");
        profile.modify(NAME, name);
        profile.setDistro(distro);
        profile.save();
        profile = lookupByName(client, name);
        return profile;
    }

    /**
     * Returns a kickstart profile matching the given name or null
     * @param client the xmlrpc client
     * @param name the profile name
     * @return the profile that maps to the name or null
     */
    public static Profile lookupByName(CobblerConnection client, String name) {
        Map <String, Object> map = (Map<String, Object>)client.
                                    invokeTokenMethod("get_profile", name);
        if (map == null || map.isEmpty()) {
            return null;
        }
        
        Profile profile = new Profile(client);
        profile.handle = (String) client.invokeTokenMethod("get_profile_handle", name);
        profile.dataMap = map;
        return profile;
    }

    /**
     *  Returns the profile matching the given uid or null
     * @param client client the xmlrpc client  
     * @param id the uid of the profile
     * @return the profile matching the given uid or null
     */
    public static Profile lookupById(CobblerConnection client, String id) {
        List<Map<String, Object>> profiles = (List<Map<String, Object>>) 
                                                client.invokeTokenMethod("get_profiles");
        Profile profile = new Profile(client);
        for (Map <String, Object> map : profiles) {
            profile.dataMap = map;
            if (id.equals(profile.getUid())) {
                profile.handle = (String) client.invokeTokenMethod
                                        ("get_profile_handle", profile.getName());
                return profile;
            }
        }
        return null;
    }    

    /**
     * Returns a list of available profiles 
     * @param connection the cobbler connection
     * @return a list of profiles.
     */
    public static List<Profile> list(CobblerConnection connection) {
        List <Profile> profiles = new LinkedList<Profile>();
        List <Map<String, Object >> cProfiles = (List <Map<String, Object >>) 
                                        connection.invokeTokenMethod("get_profiles");
        
        for (Map<String, Object> profMap : cProfiles) {
            Profile profile = new Profile(connection);
            profile.dataMap = profMap;
            profiles.add(profile);
        }
        return profiles;
    }
    
    private void modify(String key, Object value) {
        client.invokeTokenMethod("modify_profile", handle, key, value);
        dataMap.put(key, value);
    }
    
    /**
     * calls save_profile to complete the commit
     */
    public void save() {
        client.invokeTokenMethod("save_profile", handle);
        client.invokeTokenMethod("update");
    }

    /**
     * removes the kickstart profile from cobbler.
     */
    public void remove() {
        client.invokeTokenMethod("remove_profile", getName());
        client.invokeTokenMethod("update");
    }
    
    /**
     * reloads the kickstart profile.
     */
    public void reload() {
        Profile newProfile = lookupById(client, getId());
        dataMap = newProfile.dataMap;
        handle = newProfile.handle;
    }
    
    /**
     * @return the comment
     */
    public String getComment() {
        return (String)dataMap.get(COMMENT);
    }

    
    /**
     * @param commentIn the comment to set
     */
    public void setComment(String commentIn) {
        modify(COMMENT, commentIn);
    }
    
    /**
     * @return the managementClasses
     */
    public List<String> getManagementClasses() {
        return (List<String>)dataMap.get(MGMT_CLASSES);
    }

    
    /**
     * @param managementClassesIn the managementClasses to set
     */
    public void setManagementClasses(List<String> managementClassesIn) {
        modify(MGMT_CLASSES, managementClassesIn);
    }

    
    /**
     * @return the templateFiles
     */
    public Map<String, String> getTemplateFiles() {
        return (Map<String, String>)dataMap.get(TEMPLATE_FILES);
    }

    
    /**
     * @param templateFilesIn the templateFiles to set
     */
    public void setTemplateFiles(Map<String, String> templateFilesIn) {
        modify(TEMPLATE_FILES, templateFilesIn);
    }

    
    /**
     * @return the uid
     */
    public String getUid() {
        return (String)dataMap.get(UID);
    }

    /**
     * @return the uid
     */
    public String getId() {
        return getUid();
    }
    
    /**
     * @param uidIn the uid to set
     */
    public void setUid(String uidIn) {
        modify(UID, uidIn);
    }

    
    /**
     * @return the parent
     */
    public String getParent() {
        return (String)dataMap.get(PARENT);
    }

    
    /**
     * @param parentIn the parent to set
     */
    public void setParent(String parentIn) {
        modify(PARENT, parentIn);
    }
    
    /**
     * @return the owners
     */
    public List<String> getOwners() {
        return (List<String>)dataMap.get(OWNERS);
    }

    
    /**
     * @param ownersIn the owners to set
     */
    public void setOwners(List<String> ownersIn) {
        modify(OWNERS, ownersIn);
    }

    
    /**
     * @return the created
     */
    public Date getCreated() {
        return (Date)dataMap.get(CTIME);
    }

    
    /**
     * @param createdIn the created to set
     */
    public void setCreated(Date createdIn) {
        modify(CTIME, createdIn);
    }

    
    /**
     * @return the modified
     */
    public Date getModified() {
        return (Date)dataMap.get(MTIME);
    }

    
    /**
     * @param modifiedIn the modified to set
     */
    public void setModified(Date modifiedIn) {
        modify(MTIME, modifiedIn);
    }

    /**
     * @return the depth
     */
    public int getDepth() {
        return (Integer)dataMap.get(DEPTH);
    }

    
    /**
     * @param depthIn the depth to set
     */
    public void setDepth(int depthIn) {
        modify(DEPTH, depthIn);
    }

    
    /**
     * @return the kernelOptions
     */
    public Map<String, Object> getKernelOptions() {
        return (Map<String, Object>)dataMap.get(KERNEL_OPTIONS);
    }

    
    /**
     * @param kernelOptionsIn the kernelOptions to set
     */
    public void setKernelOptions(Map<String, Object> kernelOptionsIn) {
        modify(KERNEL_OPTIONS, kernelOptionsIn);
    }

    
    /**
     * @return the kernelMeta
     */
    public Map<String, Object> getKsMeta() {
        return (Map<String, Object>)dataMap.get(KS_META);
    }

    
    /**
     * @param kernelMetaIn the kernelMeta to set
     */
    public void setKsMeta(Map<String, Object> kernelMetaIn) {
        modify(KS_META, kernelMetaIn);
    }

    
    /**
     * @return the name
     */
    public String getName() {
        return (String)dataMap.get(NAME);
    }

    /**
     * @param nameIn sets the new name
     */
    public void setName(String nameIn) {
        client.invokeTokenMethod("rename_profile", handle, nameIn);
        client.invokeTokenMethod("update", handle, nameIn);
        dataMap.put(NAME, nameIn);
        reload();
    }
    
    
    /**
     * @return the kernelPostOptions
     */
    public Map<String, Object> getKernelPostOptions() {
        return (Map<String, Object>)dataMap.get(KERNEL_OPTIONS_POST);
    }

    
    /**
     * @param kernelPostOptionsIn the kernelPostOptions to set
     */
    public void setKernelPostOptions(Map<String, Object> kernelPostOptionsIn) {
        modify(KERNEL_OPTIONS_POST, kernelPostOptionsIn);
    }

    /**
     * @return the DhcpTag
     */
     public String getDhcpTag() {
         return (String)dataMap.get(DHCP_TAG);
     }

     /**
     * @return the Kickstart file path
     */
     public String getKickstart() {
         return (String)dataMap.get(KICKSTART);
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
     * @return the Repos
     */
     public List<String> getRepos() {
         return (List<String>)dataMap.get(REPOS);
     }

     /**
     * @return the VirtPath
     */
     public String getVirtPath() {
         return (String)dataMap.get(VIRT_PATH);
     }

     /**
     * @return the Server
     */
     public String getServer() {
         return (String)dataMap.get(SERVER);
     }

     /**
     * @return the NameServers
     */
     public String getNameServers() {
         return (String)dataMap.get(NAME_SERVERS);
     }

     /**
     * @return true if menu enabled
     */
     public boolean menuEnabled() {
         return 1 == (Integer)dataMap.get(ENABLE_MENU);
     }

     /**
     * @return the VirtFileSize
     */
     public long getVirtFileSize() {
         return (Long)dataMap.get(VIRT_FILE_SIZE);
     }

     /**
     * @return the VirtRam
     */
     public long getVirtRam() {
         return (Long)dataMap.get(VIRT_RAM);
     }

     /**
     * @return the Distro
     */
     public Distro getDistro() {
         String distroName = (String)dataMap.get(DISTRO);
         return Distro.lookupByName(client, distroName);
     }
     
     /**
      * @param dhcpTagIn the DhcpTag
      */
      public void  setDhcpTag(String dhcpTagIn) {
          modify(DHCP_TAG, dhcpTagIn);
      }

      /**
      * @param kickstartIn the Kickstart
      */
      public void  setKickstart(String kickstartIn) {
          modify(KICKSTART, kickstartIn);
      }

      /**
      * @param virtBridgeIn the VirtBridge
      */
      public void  setVirtBridge(String virtBridgeIn) {
          modify(VIRT_BRIDGE, virtBridgeIn);
      }

      /**
      * @param virtCpusIn the VirtCpus
      */
      public void  setVirtCpus(int virtCpusIn) {
          modify(VIRT_CPUS, virtCpusIn);
      }

      /**
      * @param virtTypeIn the VirtType
      */
      public void  setVirtType(String virtTypeIn) {
          modify(VIRT_TYPE, virtTypeIn);
      }

      /**
      * @param reposIn the Repos
      */
      public void  setRepos(List<String> reposIn) {
          modify(REPOS, reposIn);
      }

      /**
      * @param virtPathIn the VirtPath
      */
      public void  setVirtPath(String virtPathIn) {
          modify(VIRT_PATH, virtPathIn);
      }

      /**
      * @param serverIn the Server
      */
      public void  setServer(String serverIn) {
          modify(SERVER, serverIn);
      }

      /**
      * @param nameServersIn the NameServers
      */
      public void  setNameServers(String nameServersIn) {
          modify(NAME_SERVERS, nameServersIn);
      }

      /**
      * @param enableMenuIn the EnableMenu
      */
      public void  setEnableMenu(boolean enableMenuIn) {
          modify(ENABLE_MENU, enableMenuIn ? 1 : 0);
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
      * @param distroIn the Distro
      */
      public void  setDistro(Distro distroIn) {
          setDistro(distroIn.getName());
      }


      /**
      * @param name the Distr name
      */
      public void  setDistro(String name) {
          modify(DISTRO, name);
      }
      
}
