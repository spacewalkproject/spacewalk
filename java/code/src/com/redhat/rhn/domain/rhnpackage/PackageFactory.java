/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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
package com.redhat.rhn.domain.rhnpackage;

import com.redhat.rhn.common.db.datasource.CachedStatement;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.server.InstalledPackage;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.channel.PackageSearchAction;
import com.redhat.rhn.frontend.dto.BooleanWrapper;
import com.redhat.rhn.frontend.dto.PackageOverview;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.log4j.Logger;
import org.hibernate.Session;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * PackageFactory
 * @version $Rev$
 */
public class PackageFactory extends HibernateFactory {

    private static PackageFactory singleton = new PackageFactory();
    private static Logger log = Logger.getLogger(PackageFactory.class);

    public static final PackageKeyType PACKAGE_KEY_TYPE_GPG = lookupKeyTypeByLabel("gpg");

    public static final String ARCH_TYPE_RPM = "rpm";
    public static final String ARCH_TYPE_SYSV = "sysv-solaris";
    public static final String ARCH_TYPE_TAR = "tar";
    public static final String ARCH_TYPE_PATCH = "solaris-patch";
    public static final String ARCH_TYPE_PATCH_CLUSTER = "solaris-patch-cluster";

    private PackageFactory() {
        super();
    }

    /**
     * Get the Logger for the derived class so log messages show up on the
     * correct class
     */
    protected Logger getLogger() {
        return log;
    }

    /**
     * Lookup a Package by its ID
     * @param id to search for
     * @return the Package found
     */
    private static Package lookupById(Long id) {
        Map params = new HashMap();
        params.put("id", id);
        return (Package) singleton.lookupObjectByNamedQuery("Package.findById", params);
    }

    /**
     * Returns true if the Package with the given name and evr ids exists in the
     * Channel whose id is cid.
     * @param cid Channel id to look in
     * @param nameId Package name id
     * @param evrId Package evr id
     * @return true if the Package with the given name and evr ids exists in the
     * Channel whose id is cid.
     */
    public static boolean isPackageInChannel(Long cid, Long nameId, Long evrId) {
        Map params = new HashMap();
        params.put("cid", cid);
        params.put("name_id", nameId);
        params.put("evr_id", evrId);
        SelectMode m = ModeFactory.getMode("Channel_queries", "is_package_in_channel");
        DataResult dr = m.execute(params);
        if (dr.isEmpty()) {
            return false;
        }

        BooleanWrapper bw = (BooleanWrapper) dr.get(0);
        return bw.booleanValue();
    }

    /**
     * Lookup a Package by the id, in the context of a given user. Does security
     * check to verify that the user has access to the package.
     * @param id of the Package to search for
     * @param user the user doing the search
     * @return the Package found
     */
    public static Package lookupByIdAndUser(Long id, User user) {
        return lookupByIdAndOrg(id, user.getOrg());
    }

    /**
     * Lookup a Package by the id, in the context of a given org. Does security
     * check to verify that the org has access to the package.
     * @param id of the Package to search for
     * @param org the org which much have access to the package
     * @return the Package found
     */
    public static Package lookupByIdAndOrg(Long id, Org org) {
        if (!UserManager.verifyPackageAccess(org, id)) {
            // User doesn't have access to the package... return null as if it
            // doesn't exist.
            return null;
        }
        Package pkg = lookupById(id);
        return pkg;
    }

    /**
     * Store the package provider.
     * @param prov The object we are commiting.
     */
    public static void save(PackageProvider prov) {
        singleton.saveObject(prov);
    }

    /**
     * Store the package delta.
     * @param delta The object we are commiting.
     */
    public static void save(PackageDelta delta) {
        singleton.saveObject(delta);
    }

    /**
     * Lookup a PackageArch by its id.
     * @param id package arch label id sought.
     * @return the PackageArch whose id matches the given id.
     */
    public static PackageArch lookupPackageArchById(Long id) {
        Map params = new HashMap();
        params.put("id", id);
        return (PackageArch) singleton.lookupObjectByNamedQuery("PackageArch.findById",
                params, true);
    }

    /**
     * Lookup a PackageArch by its label.
     * @param label package arch label sought.
     * @return the PackageArch whose label matches the given label.
     */
    public static PackageArch lookupPackageArchByLabel(String label) {
        Map params = new HashMap();
        params.put("label", label);
        return (PackageArch) singleton.lookupObjectByNamedQuery("PackageArch.findByLabel",
                params, true);
    }

    /**
     * List the Package objects by their Package Name
     * @param pn to query by
     * @return List of Package objects if found
     */
    public static List listPackagesByPackageName(PackageName pn) {
        Session session = HibernateFactory.getSession();

        return session.getNamedQuery("Package.findByPackageName").setEntity("packageName",
                pn).list();

    }

    /**
     * lookup a PackageName object based on it's name, If one does not exist,
     * create a new one and return it.
     * @param pn the package name
     * @return a PackageName object that has a matching name
     */
    public static synchronized PackageName lookupOrCreatePackageByName(String pn) {
        PackageName returned = lookupPackageName(pn);

        if (returned == null) {
            PackageName newName = new PackageName();
            newName.setName(pn);
            singleton.saveObject(newName);
            return newName;
        }
        return returned;
    }

    /**
     * lookup a PackageName object based on it's id, returns null if it does
     * not exist
     *
     * @param id the package name id
     * @return a PackageName object that has a matching id or null if that
     * doesn't exist
     */
     public static PackageName lookupPackageName(Long id) {
        PackageName returned = (PackageName) HibernateFactory.getSession().getNamedQuery(
                "PackageName.findById").setLong("id", id).uniqueResult();
        return returned;
    }

    /**
     * lookup a PackageName object based on it's name, returns null if it does
     * not exist
     *
     * @param pn the package name
     * @return a PackageName object that has a matching name or null if that
     * doesn't exist
     */
    private static PackageName lookupPackageName(String pn) {
        PackageName returned = (PackageName) HibernateFactory.getSession().getNamedQuery(
                "PackageName.findByName").setString("name", pn).uniqueResult();
        return returned;
    }

    /**
     * lookup orphaned packages, i.e. packages that are not contained in any
     * channel
     * @param org the org to check for
     * @return a List of package objects that are not in any channel
     */
    public static List lookupOrphanPackages(Org org) {
        return HibernateFactory.getSession().getNamedQuery("Package.listOrphans")
                .setEntity("org", org).list();
    }

    /**
     * Find a package based off of the NEVRA
     * @param org the org that owns the package
     * @param name the name to search for
     * @param version the version to search for
     * @param release the release to search for
     * @param epoch if epoch is null, the best match for epoch will be used.
     * @param arch the arch to search for
     * @return the requested Package
     */
    public static List<Package> lookupByNevra(Org org, String name, String version,
            String release, String epoch, PackageArch arch) {

        List<Package> packages = HibernateFactory.getSession().getNamedQuery(
                "Package.lookupByNevra").setEntity("org", org).setString("name", name)
                .setString("version", version).setString("release", release).setEntity(
                        "arch", arch).list();

        if (epoch == null || packages.size() < 2) {
            return packages;
        }
        for (Package pack : packages) {
            if (!epoch.equals(pack.getPackageEvr().getEpoch())) {
                packages.remove(pack);
            }
        }
        return packages;
    }

    /**
     * Returns an InstalledPackage object, given a server and package name to
     * lookup the latest version of the package. Return null if the package
     * doesn;t exist.
     * @param name name of the package to lookup on
     * @param server server where the give package was installed.
     * @return the InstalledPackage with the given package name for the given
     * server
     */
    public static InstalledPackage lookupByNameAndServer(String name, Server server) {
        PackageName packName = lookupPackageName(name);
        Map params = new HashMap();
        params.put("server", server);
        params.put("name", packName);

        List<InstalledPackage> original = singleton.listObjectsByNamedQuery(
                "InstalledPackage.lookupByServerAndName", params);
        if (original.isEmpty()) {
            return null;
        }
        if (original.size() == 1) {
            return original.get(0);
        }
        List<InstalledPackage> packs = new LinkedList<InstalledPackage>();
        packs.addAll(original);
        Collections.sort(packs);
        return packs.get(packs.size() - 1);
    }

    /**
     * Returns PackageOverviews from a search.
     * @param pids List of package ids returned from search server.
     * @param archLabels List of channel arch labels.
     * @param relevantUserId user id to filter by if relevant or architecture search
     *   server the user can see is subscribed to
     * @param filterChannelId channel id to filter by if channel search
     * @param searchType type of search to do, one of "relevant", "channel",
     *   "architecture", or "all"
     * @return PackageOverviews from a search.
     */
    public static List<PackageOverview> packageSearch(List<Long> pids,
            List<String> archLabels, Long relevantUserId, Long filterChannelId,
            String searchType) {
        Map<String, Object> params = new HashMap<String, Object>();
        SelectMode m = null;

        if (searchType.equals(PackageSearchAction.ARCHITECTURE)) {
            if (!(archLabels != null && archLabels.size() > 0)) {
                throw new MissingArchitectureException(
                        "archLabels must not be null for architecture search!");
            }

            // This makes me very sad. PreparedSatement.setObject does not allow
            // you to pass in Lists or Arrays. We can't manually convert archLabels
            // to a string and use the regular infrastructure because it will
            // escape the quotes between architectures. The only thing we can do
            // is to get the SelectMode and manually insert the architecture types
            // before we continue. If we can get PreparedStatement to accept Lists
            // then all this hackishness can go away. NOTE: we know that we have to
            // guard against sql injection in this case. Notice that the archLabels
            // will all be enclosed in single quotes. Valid archLabels will only
            // contain alphanumeric, '-', and "_" characters. We will simply
            // check and enforce that constraint, and then even if someone injected
            // something we would either end up throwing an error or it would be
            // in a string, and therefore not dangerous.
            m = ModeFactory.getMode("Package_queries", "searchByIdAndArches");
            CachedStatement cs = m.getQuery();
            String query = cs.getOrigQuery();
            String archString = "'" + sanitizeArchLabel(archLabels.get(0)) + "'";
            for (int i = 1; i < archLabels.size(); i++) {
                archString += ", '" + sanitizeArchLabel(archLabels.get(i)) + "'";
            }
            query = query.replace(":channel_arch_labels", archString);
            cs.setQuery(query);
            m.setQuery(cs);
        }
        else if (searchType.equals(PackageSearchAction.RELEVANT)) {
            if (relevantUserId == null) {
                throw new IllegalArgumentException(
                        "relevantUserId must not be null for relevant search!");
            }
            params.put("uid", relevantUserId);
            m = ModeFactory.getMode("Package_queries", "relevantSearchById");
        }
        else if (searchType.equals(PackageSearchAction.CHANNEL)) {
            if (filterChannelId == null) {
                throw new IllegalArgumentException(
                        "filterChannelId must not be null for channel search!");
            }
            params.put("cid", filterChannelId);
            m = ModeFactory.getMode("Package_queries", "searchByIdInChannel");
        }
        else {
            m = ModeFactory.getMode("Package_queries", "searchById");
        }

        // SelectMode.execute will batch the size properly and CachedStatement.execute
        // will create a comma separated string representation of the list of pids
        DataResult result = m.execute(params, pids);
        result.elaborate();
        return result;
    }

    private static String sanitizeArchLabel(String archLabel) {
        // ArchLabels can only contain alphanumeric, '-', or '_' in order to guard
        // against sql injection. They will never contain anything else during the
        // normal course of operation, throw an error if the regex doesn't match.
        if (!archLabel.matches("^[a-zA-Z0-9\\-_]*$")) {
            throw new IllegalArgumentException("The channel architecture " + archLabel +
                    " is invalid! Possible sql injection attempt!");
        }
        return archLabel;
    }

    /**
     * Lookup a package key type by label
     * @param label the label of the type
     * @return the key type
     */
    public static PackageKeyType lookupKeyTypeByLabel(String label) {
        Map params = new HashMap();
        params.put("label", label);
        return (PackageKeyType) singleton.lookupObjectByNamedQuery(
                "PackageKeyType.findByLabel", params);
    }

    /**
     * Deletes a particular package object from hibernate. Note, currently This
     * does not delete it from rhnServerNeededPackageCache so you probably want
     * to use SystemManager.deletePackages() to do that instead. This does not
     * also cleanup rhNPackageSource entries
     * @param pack the package to delete
     */
    public static void deletePackage(Package pack) {
        HibernateFactory.getSession().delete(pack);

    }

    /**
     * Deletes a particular package source object
     * @param src the package source object
     */
    public static void deletePackageSource(PackageSource src) {
        HibernateFactory.getSession().delete(src);
    }

    /**
     * Lookup package sources for a particular package
     * @param pack the package associated with the package sources
     * @return the list of package source objects
     */
    public static List<PackageSource> lookupPackageSources(Package pack) {
        Map params = new HashMap();
        params.put("pack", pack);

        return singleton.listObjectsByNamedQuery("PackageSource.findByPackage", params);
    }

    /**
     * Find other packages with the same NVRE but with different arches
     * @param pack the package
     * @return List of package objects
     */
    public static List<Package> findPackagesWithDifferentArch(Package pack) {
        Map params = new HashMap();
        params.put("evr", pack.getPackageEvr());
        params.put("name", pack.getPackageName());
        params.put("arch", pack.getPackageArch());

        return singleton.listObjectsByNamedQuery("Package.findOtherArches", params);
    }

    /**
     * Provides a mapping of arch type labels to sets of capabilities (ported from the if
     * statement mess in package_type_capable of Package.pm). This should really
     * be in the DB, but it's not :{ and it needs to be ported from perl.
     *
     * @return the map of arch label -> set of capabilities
     */
    public static Map<String, Set<String>> getPackageCapabilityMap() {
        Map<String, Set<String>> map = new HashMap<String, Set<String>>();

        Set<String> rpmCaps = new HashSet<String>();
        rpmCaps.add("dependencies");
        rpmCaps.add("change_log");
        rpmCaps.add("file_list");
        rpmCaps.add("errata");
        rpmCaps.add("remove");
        rpmCaps.add("rpm");
        map.put(PackageFactory.ARCH_TYPE_RPM, rpmCaps);

        Set<String> patchCaps = new HashSet<String>();
        patchCaps.add("dependencies");
        patchCaps.add("solaris_patch");
        patchCaps.add("remove");
        map.put(PackageFactory.ARCH_TYPE_PATCH, patchCaps);

        Set<String> patchSetCaps = new HashSet<String>();
        patchSetCaps.add("solaris_patchset");
        map.put(PackageFactory.ARCH_TYPE_PATCH_CLUSTER, patchSetCaps);

        Set<String> sysVCaps = new HashSet<String>();
        sysVCaps.add("deploy_answer_file");
        sysVCaps.add("remove");
        sysVCaps.add("package_map");
        sysVCaps.add("solaris_patchable");
        map.put(PackageFactory.ARCH_TYPE_SYSV, sysVCaps);
        return map;
    }

    /**
     * list package providers
     * @return list of package providers
     */
    public static List<PackageProvider> listPackageProviders() {
        Map params = new HashMap();
        List<PackageProvider> list = singleton.listObjectsByNamedQuery(
                "PackageProvider.listProviders", params);
        return list;
    }

    /**
     * Looup a package provider by name
     * @param name the name
     * @return the package provider
     */
    public static PackageProvider lookupPackageProvider(String name) {
        Map params = new HashMap();
        params.put("name", name);
        PackageProvider prov = (PackageProvider) singleton.lookupObjectByNamedQuery(
                "PackageProvider.findByName", params);
        return prov;
    }

    /**
     * Deletes a package key
     * @param key the key to delete
     */
    public static void deletePackageKey(PackageKey key) {
        HibernateFactory.getSession().delete(key);
    }

    /**
     * Lookup a package key object
     * @param key the key to lookup
     * @return the package key
     */
    public static PackageKey lookupPackageKey(String key) {
        Map params = new HashMap();
        params.put("key", key);
        PackageKey prov = (PackageKey) singleton.lookupObjectByNamedQuery(
                "PackageKey.findByKey", params);
        return prov;
    }

    /**
     * List all package keys
     * @return list of package key objects
     */
    public static List<PackageKey> listPackageKeys() {
        Map params = new HashMap();
        List<PackageKey> prov = singleton.listObjectsByNamedQuery("PackageKey.listKeys",
                params);
        return prov;
    }

    /**
     * Returns information, whether each package in the list is channel compatible
     * and whether the org has accesds to
     * @param orgId organization id
     * @param channelId channel id
     * @param packageIds list of package ids
     * @return dataresult(id, package_arch_id, org_package, org_access, shared_access)
     */
    public static DataResult getPackagesChannelArchCompatAndOrgAccess(
            Long orgId, Long channelId, List<Long> packageIds) {
        Map params = new HashMap();
        params.put("org_id", orgId);
        params.put("channel_id", channelId);
        SelectMode m = ModeFactory.getMode("Package_queries",
                "channel_arch_and_org_access");
        return m.execute(params, packageIds);
    }
}
