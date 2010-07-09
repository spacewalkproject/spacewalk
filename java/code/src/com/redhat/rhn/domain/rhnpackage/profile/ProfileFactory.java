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
package com.redhat.rhn.domain.rhnpackage.profile;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.server.Server;

import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * ProfileFactory
 * @version $Rev$
 */
public class ProfileFactory extends HibernateFactory {

    private static ProfileFactory singleton = new ProfileFactory();

    private static Logger log = Logger.getLogger(ProfileFactory.class);
    /** The constant representing normal profile type. */
    public static final ProfileType TYPE_NORMAL = lookupByLabel("normal");
    /** The constant representing sync profile type. */
    public static final ProfileType TYPE_SYNC_PROFILE = lookupByLabel("sync_profile");



    private ProfileFactory() {
        super();
    }

    /**
     * Creates a new Profile
     * @param type Type of profile desired.
     * @return a new Profile
     * @see ProfileFactory#TYPE_NORMAL
     * @see ProfileFactory#TYPE_SYNC_PROFILE
     */
    public static Profile createProfile(ProfileType type) {
        return new Profile(type);
    }

    /**
     * Get the statetype by name.
     * @param name Name of statetype
     * @return statetype whose name matches the given name.
     */
    public static ProfileType lookupByLabel(String name) {
        Map params = new HashMap();
        params.put("label", name);
        return (ProfileType) singleton.lookupObjectByNamedQuery(
                "ProfileType.findByLabel", params, true);
    }

    /**
     * Lookup a Profile by their id
     * @param id the id to search for
     * @param org The org in which this profile should be.
     * @return the Profile found
     */
    public static Profile lookupByIdAndOrg(Long id, Org org) {
        Map params = new HashMap();
        params.put("id", id);
        params.put("org_id", org.getId());
        return (Profile) singleton.lookupObjectByNamedQuery("Profile.findByIdAndOrg",
                params, true);
    }

    /**
     * Returns a list of Profiles which are compatible with the given server.
     * @param server Server whose profiles we want.
     * @param org Org owner
     * @return  a list of Profiles which are compatible with the given server.
     */
    public static List compatibleWithServer(Server server, Org org) {
        Map params = new HashMap();
        params.put("sid", server.getId());
        params.put("org_id", org.getId());
        return singleton.listObjectsByNamedQuery(
                "Profile.compatibleWithServer", params, false);
    }

     /**
      * Store the profile.
      * @param profile The object we are commiting.
      */
    public static void save(Profile profile) {
        singleton.saveObject(profile);
    }

    /**
     * Deletes the profile.
     * @param profile The object we are deleting.
     * @return number of objects affected (usually 1 or 0).
     */
    public static int remove(Profile profile) {
        return singleton.removeObject(profile);
    }

    /**
     * {@inheritDoc}
     */
    protected Logger getLogger() {
        return log;
    }

    /**
     * Returns a Profile whose name matches the given name and is in the
     * given org, or null if none found.
     * @param name Profile name
     * @param orgid OrgId which owns profile.
     * @return a Profile whose name matches the given name and is in the
     * given org, or null if none found.
     */
    public static Profile findByNameAndOrgId(String name, Long orgid) {
        Map params = new HashMap();
        params.put("name", name);
        params.put("org_id", orgid);
        return (Profile) singleton.lookupObjectByNamedQuery(
                "Profile.findByNameAndOrgId", params, true);
    }

}
