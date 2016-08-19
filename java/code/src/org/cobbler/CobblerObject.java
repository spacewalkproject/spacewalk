/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import com.redhat.rhn.common.util.StringUtil;

import org.apache.commons.lang.StringUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;


/**
 * Base class has attributes common to
 * distros, profiles, system records
 * @author paji
 * @version $Rev$
 */
public abstract class CobblerObject {
    protected static final String COMMENT = "comment";
    protected static final String OWNERS = "owners";
    protected static final String CTIME = "ctime";
    protected static final String KERNEL_OPTIONS_POST = "kernel_options_post";
    protected static final String SET_KERNEL_OPTIONS_POST = "kopts_post";
    protected static final String DEPTH = "depth";
    protected static final String KERNEL_OPTIONS = "kernel_options";
    protected static final String SET_KERNEL_OPTIONS = "kopts";
    protected static final String NAME = "name";
    protected static final String KS_META = "ks_meta";
    protected static final String SET_KS_META = "ksmeta";
    protected static final String PARENT = "parent";
    protected static final String MTIME = "mtime";
    protected static final String MGMT_CLASSES = "mgmt_classes";
    protected static final String TEMPLATE_FILES = "template_files";
    protected static final String UID = "uid";

    private static final String REDHAT_KEY = "redhat_management_key";
    public static final String INHERIT_KEY = "<<inherit>>";

    protected String handle;
    protected Map<String, Object> dataMap = new HashMap<String, Object>();
    protected CobblerConnection client;

    /**
     * Helper method used by all cobbler objects to
     * return a version of themselves by UID
     * @see org.cobbler.Distro.lookupById for example usage..
     *
     * @param client the Cobbler Connection
     * @param id the UID of the distro/profile/system record
     * @param findMethod the find xmlrpc method, eg: find_distro
     * @return true if the cobbler object was found.
     */
    protected static Map<String, Object> lookupDataMapById(CobblerConnection client,
                             String id, String findMethod) {
        if (id == null) {
            return null;
        }
        List<Map<String, Object>> objects = lookupDataMapsByCriteria(client,
                                                            UID, id, findMethod);
        if (!objects.isEmpty()) {
            return objects.get(0);
        }
        return null;

    }

    /**
     * look up data maps by a certain criteria
     * @param client the xmlrpc client
     * @param critera (i.e. uid profile, etc..)
     * @param value the value of the criteria
     * @param findMethod the find method to use (find_system, find_profile)
     * @return List of maps
     */
    protected static List<Map<String, Object>> lookupDataMapsByCriteria(
            CobblerConnection client, String critera, String value, String findMethod) {
        if (value == null) {
            return null;
        }

        Map<String, String> criteria  = new HashMap<String, String>();
        criteria.put(critera, value);
        List<Map<String, Object>> objects = (List<Map<String, Object>>)
                                client.invokeTokenMethod(findMethod, criteria);
        return objects;

    }


    /**
     * Helper method used by all cobbler objects to
     * return a Map of themselves by name.
     * @see org.cobbler.Distro.lookupByName for example usage..
     * @param client  the Cobbler Connection
     * @param name the name of the cobbler object
     * @param lookupMethod the name of the xmlrpc
     *                       method to lookup: eg get_profile for profile
     * @return the Cobbler Object Data Map or null
     */
    protected static Map <String, Object> lookupDataMapByName(CobblerConnection client,
                                    String name, String lookupMethod) {
        Object obj = client.invokeMethod(lookupMethod, name);
        if ("~".equals(obj)) {
            return null;
        }
        Map <String, Object> map = (Map<String, Object>) obj;
        if (map == null || map.isEmpty()) {
            return null;
        }
        return map;
    }

    protected abstract void invokeModify(String key, Object value);
    protected abstract void invokeSave();
    protected abstract boolean invokeRemove();
    protected abstract String invokeGetHandle();
    protected abstract void reload();
    protected abstract void invokeRename(String newName);

    protected String getHandle() {
        if (isBlank(handle)) {
            handle = invokeGetHandle();
        }
        return handle;
    }

    protected void modify(String key, Object value) {
        invokeModify(key, value);
        dataMap.put(key, value);
    }

    /**
     * calls save object to complete the commit
     */
    public void save() {
        invokeSave();
        update();
    }

    /**
     * removes the kickstart object from cobbler.
     * @return true if sucessfull
     */
    public boolean remove() {
        return invokeRemove();
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
        Double time = (Double)dataMap.get(CTIME);
        // cobbler deals with seconds since epoch, Date expects milliseconds. Convert.
        return new Date(time.longValue() * 1000);
    }

    /**
     * @param createdIn the created to set
     */
    public void setCreated(Date createdIn) {
        // cobbler deals with seconds since epoch, Date returns milliseconds. Convert.
        modify(CTIME, createdIn.getTime() / 1000);
    }

    /**
     * @return the modified
     */
    public Date getModified() {
        Double time = (Double) dataMap.get(MTIME);
        // cobbler deals with seconds since epoch, Date expects milliseconds. Convert.
        return new Date(time.longValue() * 1000);
    }

    /**
     * @param modifiedIn the modified to set
     */
    public void setModified(Date modifiedIn) {
        // cobbler deals with seconds since epoch, Date returns milliseconds. Convert.
        modify(MTIME, modifiedIn.getTime() / 1000);
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
     * gets the kernel options in string form
     * @return the string
     */
    public String getKernelOptionsString() {
        return convertOptionsMap(getKernelOptions());
    }

    /**
     * gets the kernel post options in string form
     * @return the string
     */
    public String getKernelPostOptionsString() {
        return convertOptionsMap(getKernelPostOptions());
    }

    private String convertOptionsMap(Map<String, Object> map) {
        StringBuilder string = new StringBuilder();
        for (String key : map.keySet()) {
            List<String> keyList;
            try {
                 keyList = (List)map.get(key);
            }
            catch (ClassCastException e) {
                keyList = new ArrayList<String>();
                keyList.add((String) map.get(key));
            }
            if (keyList.isEmpty()) {
                string.append(key + " ");
            }
            else {
                for (String value : keyList) {
                    string.append(key + "=" + value + " ");
                }
            }
        }
        return string.toString();
    }


    /**
     * @param kernelOptionsIn the kernelOptions to set
     */
    public void setKernelOptions(Map<String, Object> kernelOptionsIn) {
        modify(SET_KERNEL_OPTIONS, kernelOptionsIn);
    }

    /**
     * @param kernelOptsIn the kernelOptions to set
     */
    public void setKernelOptions(String kernelOptsIn) {
        setKernelOptions(parseKernelOpts(kernelOptsIn));
    }


    /**
     * @param kernelOptsIn the kernelOptions to set
     */
    public void setKernelPostOptions(String kernelOptsIn) {
        setKernelPostOptions(parseKernelOpts(kernelOptsIn));
    }

    private Map<String, Object> parseKernelOpts(String kernelOpts) {
        Map<String, Object> toRet = new HashMap<String, Object>();

        if (StringUtils.isEmpty(kernelOpts)) {
            return toRet;
        }

        String[] options = StringUtils.split(kernelOpts);
        for (String option : options) {
            String[] split = option.split("=", 2);
            if (split.length == 1) {
                toRet.put(split[0], new ArrayList<String>());
            }
            else if (split.length == 2) {
                if (toRet.containsKey(split[0])) {
                    List<String> list = (List)toRet.get(split[0]);
                    list.add(split[1]);
                }
                else {
                    toRet.put(split[0], new ArrayList<String>(Arrays.asList(split[1])));
                }
            }
        }
        return toRet;
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
    public void setKsMeta(Map<String, ? extends Object> kernelMetaIn) {
        modify(SET_KS_META, kernelMetaIn);
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
        invokeRename(nameIn);
        dataMap.put(NAME, nameIn);
        handle = null;
        handle = getHandle();
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
        modify(SET_KERNEL_OPTIONS_POST, kernelPostOptionsIn);
    }

    protected void update() {
        client.invokeTokenMethod("update");
    }

    protected boolean isBlank(String str) {
        return str == null || str.trim().length() == 0;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString() {
        return "DataMap = " + dataMap;
    }

    /**
     * @param key the red hat activation key
     */
    public void setRedHatManagementKey(String key) {
        modify(REDHAT_KEY, key);
    }

    /**
     * @param keys the red hat activation keys in a set
     */
    public void setRedHatManagementKey(Set<String> keys) {
        modify(REDHAT_KEY, StringUtils.defaultString(StringUtil.join(",", keys)));
    }

    /**
     * get the red hat management key
     * @return returns the red hat key as a string
     */
    public String getRedHatManagementKey() {
        return (String) dataMap.get(REDHAT_KEY);
    }

    /**
     * get the redhate management key as a Set of keys
     * @return returns the red hat key as a string
     */
    public Set<String> getRedHatManagementKeySet() {
        String keys = StringUtils.defaultString(getRedHatManagementKey());
        String[] sets = (keys).split(",");
        Set set = new HashSet();
        set.addAll(Arrays.asList(sets));
        return set;
    }

    /**
     * remove the specified keys from the key set and add the specified set
     * @param keysToRemove list of tokens to remove
     * @param keysToAdd list of tokens to add
     */
    public void syncRedHatManagementKeys(Collection<String> keysToRemove,
                                            Collection<String> keysToAdd) {
        Set<String> keySet = getRedHatManagementKeySet();
        keySet.removeAll(keysToRemove);
        keySet.addAll(keysToAdd);
        if (keySet.size() > 1 && keySet.contains(INHERIT_KEY)) {
            keySet.remove(INHERIT_KEY);
        }
        else if (keySet.isEmpty()) {
            keySet.add(INHERIT_KEY);
        }
        setRedHatManagementKey(keySet);
    }

}
