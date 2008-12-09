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
public class Distro {
    private String handle;
    private Map<String, Object> dataMap = new HashMap<String, Object>();
    private CobblerConnection client;
    private static final String COMMENT = "comment";
    private static final String KERNEL = "kernel";
    private static final String OWNERS = "owners";
    private static final String CTIME = "ctime";
    private static final String KERNEL_OPTIONS_POST = "kernel_options_post";
    private static final String ARCH = "arch";
    private static final String BREED = "breed";
    private static final String DEPTH = "depth";
    private static final String KERNEL_OPTIONS = "kernel_options";
    private static final String NAME = "name";
    private static final String KS_META = "ks_meta";
    private static final String OS_VERSION = "os_version";
    private static final String INITRD = "initrd";
    private static final String SOURCE_REPOS = "source_repos";
    private static final String PARENT = "parent";
    private static final String MTIME = "mtime";
    private static final String TREE_BUILD_TIME = "tree_build_time";
    private static final String MGMT_CLASSES = "mgmt_classes";
    private static final String TEMPLATE_FILES = "template_files";
    private static final String UID = "uid";

    private Distro(CobblerConnection clientIn) {
        client = clientIn;
    }
  
    /**
     * Create a new distro in cobbler
     * @param client the xmlrpc client
     * @param name the name of the distro
     * @param kernel the kernel path of the distro
     * @param initrd the initrd path of the distro
     * @return a new Distro
     */
    public static Distro create(CobblerConnection client, 
                                String name, String kernel, String initrd) {
        Distro distro = new Distro(client);
        distro.handle = (String) client.invokeTokenMethod("new_distro");
        distro.modify(NAME, name);
        distro.setKernel(kernel);
        distro.setInitrd(initrd);
        distro.save();
        distro = lookupByName(client, name);
        return distro;
    }

    /**
     * Returns a distro matching the given name or null
     * @param client the xmlrpc client
     * @param name the distro name
     * @return the distro that maps to the name or null
     */
    public static Distro lookupByName(CobblerConnection client, String name) {
        Map <String, Object> map = (Map<String, Object>)client.
                                    invokeTokenMethod("get_distro", name);
        if (map == null || map.isEmpty()) {
            return null;
        }
        Distro distro = new Distro(client);
        distro.dataMap = map;
        return distro;
    }

    /**
     * Returns a distro matching the given uid or null
     * @param client the xmlrpc client
     * @param id the uid to search for
     * @return the distro matching the UID
     */
    public static Distro lookupById(CobblerConnection client, String id) {
        List<Map<String, Object>> distros = (List<Map<String, Object>>) 
                                                client.invokeTokenMethod("get_distros");
        Distro distro = new Distro(client);
        for (Map <String, Object> map : distros) {
            distro.dataMap = map;
            if (id.equals(distro.getUid())) {
                return distro;
            }
        }
        return null;
    }    

    /**
     * Returns a list of available Distros 
     * @param connection the cobbler connection
     * @return a list of Distros.
     */
    public static List<Distro> list(CobblerConnection connection) {
        List <Distro> distros = new LinkedList<Distro>();
        List <Map<String, Object >> cDistros = (List <Map<String, Object >>) 
                                        connection.invokeTokenMethod("get_distros");
        
        for (Map<String, Object> distroMap : cDistros) {
            Distro distro = new Distro(connection);
            distro.dataMap = distroMap;
            distros.add(distro);
        }
        return distros;
    }

    private String getHandle() {
        if (handle == null || "".equals(handle.trim())) {
            handle = (String)client.invokeTokenMethod("get_distro_handle");
        }
        return handle;
    }
    
    private void modify(String key, Object value) {
        client.invokeTokenMethod("modify_distro", getHandle(), key, value);
        dataMap.put(key, value);
    }
    
    /**
     * Save the distro
     */
    public void save() {
        client.invokeTokenMethod("save_distro", getHandle());
        client.invokeTokenMethod("update");
    }

    /**
     * Remove the distro 
     */
    public void remove() {
        client.invokeTokenMethod("remove_distro", getName());
        client.invokeTokenMethod("update");
    }
    
    /**
     * Reloads the distro
     */
    public void reload() {
        Distro newDistro = lookupById(client, getId());
        dataMap = newDistro.dataMap;
    }
    
    /**
     * @return the arch
     */
    public String getArch() {
        return (String)dataMap.get(ARCH);
    }

    
    /**
     * @param archIn the arch to set
     */
    public void setArch(String archIn) {
        modify(ARCH, archIn);
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
     * @return the kernelPath
     */
    public String getKernel() {
        return (String)dataMap.get(KERNEL);
    }

    
    /**
     * @param kernelPathIn the kernelPath to set
     */
    public void setKernel(String kernelPathIn) {
        modify(KERNEL, kernelPathIn);
    }

    
    /**
     * @return the osVersion
     */
    public String getOsVersion() {
        return (String)dataMap.get(OS_VERSION);
    }

    
    /**
     * @param osVersionIn the osVersion to set
     */
    public void setOsVersion(String osVersionIn) {
        modify(OS_VERSION, osVersionIn);
    }

    
    /**
     * @return the initrdPath
     */
    public String getInitrd() {
        return (String)dataMap.get(INITRD);
    }

    
    /**
     * @param initrdPathIn the initrdPath to set
     */
    public void setInitrd(String initrdPathIn) {
        modify(INITRD, initrdPathIn);
    }

    
    /**
     * @return the sourceRepos
     */
    public List<String> getSourceRepos() {
        return (List<String>)dataMap.get(SOURCE_REPOS);
    }

    
    /**
     * @param sourceReposIn the sourceRepos to set
     */
    public void setSourceRepos(List<String> sourceReposIn) {
        modify(SOURCE_REPOS, sourceReposIn);
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
     * @return the treeBuildTime
     */
    public long getTreeBuildTime() {
        return (Long)dataMap.get(TREE_BUILD_TIME);
    }

    
    /**
     * @param treeBuildTimeIn the treeBuildTime to set
     */
    public void setTreeBuildTime(long treeBuildTimeIn) {
        modify(TREE_BUILD_TIME, treeBuildTimeIn);
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
     * @return the breed
     */
    public String getBreed() {
        return (String)dataMap.get(BREED);
    }

    
    /**
     * @param breedIn the breed to set
     */
    public void setBreed(String breedIn) {
        modify(BREED, breedIn);
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
        client.invokeTokenMethod("rename_distro", getHandle(), nameIn);
        client.invokeTokenMethod("update", getHandle(), nameIn);
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
    
}
