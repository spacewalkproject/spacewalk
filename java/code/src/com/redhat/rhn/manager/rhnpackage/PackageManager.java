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
package com.redhat.rhn.manager.rhnpackage;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.util.CompressionUtil;
import com.redhat.rhn.common.util.RpmVersionComparator;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.InstalledPackage;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PackageComparison;
import com.redhat.rhn.frontend.dto.UpgradablePackageListItem;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.manager.BaseManager;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.hibernate.HibernateException;
import org.hibernate.Session;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * PackageManager
 * @version $Rev$
 */
public class PackageManager extends BaseManager {

    private static final String REDHAT_RELEASE_PACKAGE = "redhat-release";
    private static Logger log = Logger.getLogger(PackageManager.class);
    public static final String RHNCFG = "rhncfg";
    public static final String RHNCFG_CLIENT = "rhncfg-client";
    public static final String RHNCFG_ACTIONS = "rhncfg-actions";

    // Valid dependency types
    public static final String[]
        DEPENDENCY_TYPES = {"requires", "conflicts", "obsoletes", "provides"};


    private static final String[]
        CLEANUP_QUERIES = {"requires", "provides", "conflicts", "obsoletes",
            "channels", "files", "caps", "changelogs", "locations"};


    private static final String[] EXCLUDE_SATELLITE = {"locations"};
    /**
     * Runs Package_queries.package_obsoletes query, which returns dependencies of the
     * obsolete type.
     * @param pid The package in question
     * @return Returns dependencies of type obsolete.
     */
    public static DataResult packageObsoletes(Long pid) {
        SelectMode m = ModeFactory.getMode("Package_queries", "package_obsoletes",
                                           Map.class);
        Map params = new HashMap();
        params.put("pid", pid);
        DataResult dr = m.execute(params);
        return dr;
    }

    /**
     * Runs Package_queries.package_conflicts query, which returns dependencies of the
     * conflicts type.
     * @param pid The package in question
     * @return Returns dependencies of type conflicts.
     */
    public static DataResult packageConflicts(Long pid) {
        SelectMode m = ModeFactory.getMode("Package_queries", "package_conflicts",
                                           Map.class);
        Map params = new HashMap();
        params.put("pid", pid);
        DataResult dr = m.execute(params);
        return dr;
    }

    /**
     * Runs Package_queries.package_provides query, which returns dependencies of the
     * provides type.
     * @param pid The package in question
     * @return Returns dependencies of type provides.
     */
    public static DataResult packageProvides(Long pid) {
        SelectMode m = ModeFactory.getMode("Package_queries", "package_provides",
                                           Map.class);
        Map params = new HashMap();
        params.put("pid", pid);
        DataResult dr = m.execute(params);
        return dr;
    }

    /**
     * Runs Package_queries.package_requires query, which returns dependencies of the
     * requires type.
     * @param pid The package in question
     * @return Returns dependencies of type requires.
     */
    public static DataResult packageRequires(Long pid) {
        SelectMode m = ModeFactory.getMode("Package_queries", "package_requires",
                                           Map.class);
        Map params = new HashMap();
        params.put("pid", pid);
        DataResult dr = m.execute(params);
        return dr;
    }


    /**
     * List the package in a channel (for the web UI lists)
     * @param cid the channel id
     * @return the list of packages
     */
    public static DataResult listPackagesInChannelForList(Long cid) {
        SelectMode m = ModeFactory.getMode("Package_queries", "packages_in_channel");
        Map params = new HashMap();
        params.put("cid", cid);
        DataResult dr = m.execute(params);
        return dr;
    }


    /**
     * Runs Channel_queries.org_pkg_channels query.
     * @param orgId The id of the org for the logged in user
     * @param pid The id of the package in question
     * @return Returns a list of channels that provide the given package
     */
    public static DataResult orgPackageChannels(Long orgId, Long pid) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "org_pkg_channels",
                                           Map.class);
        Map params = new HashMap();
        params.put("pid", pid);
        params.put("org_id", orgId);
        DataResult dr = m.execute(params);
        return dr;
    }

    /**
     * Runs Channel_queries.org.pkg_channel_ids query
     * @param orgId The id of the org for the logged in user
     * @param pid The id of the package in question
     * @return Returns a list of channel ids which provide the given package
     */
    public static DataResult orgPackageChannelIds(Long orgId, Long pid) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "org_pkg_channel_ids",
                Map.class);
        Map params = new HashMap();
        params.put("pid", pid);
        params.put("org_id", orgId);
        DataResult dr = m.execute(params);
        return dr;
    }

    /**
     * Returns the erratas providing a given package
     * @param orgId The id of the org for the logged in user
     * @param pid The package id for the package in question
     * @return Returns a list of errata that provide the given package
     */
    public static DataResult providingErrata(Long orgId, Long pid) {
        SelectMode m = ModeFactory.getMode("Errata_queries", "org_pkg_errata", Map.class);
        Map params = new HashMap();
        params.put("pid", pid);
        params.put("org_id", orgId);
        DataResult dr = m.execute(params);
        return dr;
    }

    /**
     * Returns the files associated with a given package
     * @param pid The package id for the package in question
     * @return Returns a list of files associated with the package
     */
    public static DataResult packageFiles(Long pid) {
        SelectMode m = ModeFactory.getMode("Package_queries", "package_files", Map.class);
        Map params = new HashMap();
        params.put("pid", pid);
        DataResult dr = m.execute(params);
        return dr;
    }

    /**
     * Returns the providing channels for a package that the given user has access to
     * @param user The user requesting the channels
     * @param pid The package in question
     * @return Returns a list of providing channels (id, name, label) for a package
     */
    public static DataResult providingChannels(User user, Long pid) {
        SelectMode m = ModeFactory.getMode("Package_queries", "providing_channels",
                                           Map.class);
        Map params = new HashMap();
        params.put("pid", pid);
        params.put("org_id", user.getOrg().getId());
        DataResult dr = m.execute(params);
        return dr;
    }

    /**
     * Returns list of package for given server
     * @param sid Server Id
     * @param pc PageControl can also be null.
     * @return list of packages for given server
     */
    public static DataResult systemPackageList(Long sid, PageControl pc) {

        SelectMode m = ModeFactory.getMode("Package_queries", "system_package_list");
        Map params = new HashMap();
        params.put("sid", sid);
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * Returns list of package for given server
     * @param sid Server Id
     * @param pc PageControl can also be null.
     * @return list of packages for given server
     */
    public static DataResult systemAvailablePackages(Long sid, PageControl pc) {

        SelectMode m = ModeFactory.getMode("Package_queries", "system_available_packages");
        Map params = new HashMap();
        params.put("sid", sid);
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * Returns a list of downloadable packages for the given server id in the given set
     * @param label Set label
     * @param user User
     * @param sid Server id
     * @param pc PageControl
     * @return list of packages
     */
    public static DataResult downloadableInSet(String label, User user, Long sid,
                                          PageControl pc) {

        SelectMode m = ModeFactory.getMode("Package_queries",
                "package_download_for_system_arch_select");
        Map params = new HashMap();
        params.put("set_label", label);
        params.put("user_id", user.getId());
        params.put("sid", sid);
        Map elabParams = new HashMap();
        elabParams.put("sid", sid);
        return makeDataResult(params, elabParams, pc, m);

    }

    /**
     * Returns a list of upgradable packages for the given server id.
     * @param sid Server Id
     * @param pc PageControl to limit page size, maybe null for all
     * upgradable packages.
     * @return a list of UpgradablePackageListItems
     */
    public static DataResult <UpgradablePackageListItem> upgradable(Long sid,
                                                                PageControl pc) {
        SelectMode m = ModeFactory.getMode("Package_queries",
                                           "system_upgradable_package_list");

        Map params = new HashMap();
        params.put("sid", sid);

        return makeDataResult(params, params, pc, m);
    }

    /**
     * Returns a count of packages that can be upgraded on the given server.
     *
     * @param sid identifies the server
     * @return count of packages that can be upgraded
     */
    public static int countUpgradable(Long sid) {
        SelectMode m = ModeFactory.getMode("Package_queries",
                                           "count_system_upgradable_package_list");
        Map params = new HashMap();
        params.put("sid", sid);

        DataResult dr = makeDataResult(params, null, null, m);
        return ((Long)((HashMap)dr.get(0)).get("count")).intValue();
    }

    /**
     * Returns a DataResult of the packages in the set.
     * @param user User who owns set
     * @param label Set label
     * @param pc PageControl containing paging information.
     * @return DataResult of packages in the set
     */
    public static DataResult packagesInSet(User user, String label,
            PageControl pc) {

        SelectMode m = ModeFactory.getMode("Package_queries",
                                           "packages_in_set");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("set_label", label);
        if (pc != null) {
            return makeDataResult(params, params, pc, m);
        }
        DataResult dr = m.execute(params);
        dr.setTotalSize(dr.size());
        return dr;
    }

    /**
     * Finds a package by using the id column of rhnPackage
     * @param id The package id
     * @param user The user performing the lookup
     * @return A Package object
     */
    public static Package lookupByIdAndUser(Long id, User user) {
        return PackageFactory.lookupByIdAndUser(id, user);
    }

    /**
     * Returns a dataResult containing all of the packages available to an
     * errata. Picks the right query depending on whether or not the errata
     * is published.
     * @param errata The errata in question
     * @param user The user requesting the list
     * @param pc The page control for this user
     * @return Returns the list of packages available for this particular errata.
     */
    public static DataResult packagesAvailableToErrata(Errata errata,
                                                       User user,
                                                       PageControl pc) {
        Org org = errata.getOrg();

        // Get the correct query depending on whether or not this errata is published.
        String mode = "packages_available_to_tmp_errata";
        if (errata.isPublished()) {
            mode = "packages_available_to_errata";
        }

        // Setup the params and execute the query
        SelectMode m = ModeFactory.getMode("Package_queries", mode);
        Map params = new HashMap();
        params.put("org_id", org.getId());
        params.put("eid", errata.getId());
        if (pc != null) {
            return makeDataResult(params, params, pc, m);
        }
        DataResult dr = m.execute(params);
        dr.setTotalSize(dr.size());
        return dr;
    }

    /**
     * Returns a dataResult containing all of the packages available to an
     * errata. Picks the right query depending on whether or not the errata
     * is published.
     * @param errata The errata in question
     * @return Returns the list of packages available for this particular errata.
     */
    public static DataResult packagesAvailableToErrata(Errata errata) {
        Org org = errata.getOrg();

        // Get the correct query depending on whether or not this errata is published.
        String mode = "packages_available_to_tmp_errata";
        if (errata.isPublished()) {
            mode = "packages_available_to_errata";
        }

        // Setup the params and execute the query
        SelectMode m = ModeFactory.getMode("Package_queries", mode);
        Map params = new HashMap();
        params.put("org_id", org.getId());
        params.put("eid", errata.getId());

        return makeDataResult(params, params, null, m);
    }

    /**
     * Returns a data result containing all of the packages available to an errata
     * in the channel specified by cid.
     * @param errata The errata in question
     * @param cid The channel id, we want packages in this channel
     * @param user The user requesting the list
     * @param pc The page control for this user
     * @return Returns the list of packages available for this particular errata in
     * this particular channel.
     */
    public static DataResult packagesAvailableToErrataInChannel(Errata errata,
                                                                Long cid,
                                                                User user,
                                                                PageControl pc) {
        //Set the mode depending on if the errata is published
        String mode = "packages_available_to_tmp_errata_in_channel";
        if (errata.isPublished()) {
            mode = "packages_available_to_errata_in_channel";
        }

        //Setup params and execute query
        SelectMode m = ModeFactory.getMode("Package_queries", mode);
        Map params = new HashMap();
        params.put("target_eid", errata.getId().toString());
        params.put("source_cid", cid.toString());
        if (pc != null) {
            Map elabParams = new HashMap();
            elabParams.put("org_id", user.getOrg().getId());
            return makeDataResult(params, elabParams, pc, m);
        }
        DataResult dr = m.execute(params);
        dr.setTotalSize(dr.size());
        return dr;
    }

    /**
     * Returns a data result containing all of the packages available to an errata
     * in the channel specified by cid.
     * @param errata The errata in question
     * @param cid The channel id, we want packages in this channel
     * @param user The user requesting the list
     * @return Returns the list of packages available for this particular errata in
     * this particular channel.
     */
    public static DataResult packagesAvailableToErrataInChannel(Errata errata,
                                                                Long cid,
                                                                User user) {
        //Set the mode depending on if the errata is published
        String mode = "packages_available_to_tmp_errata_in_channel";
        if (errata.isPublished()) {
            mode = "packages_available_to_errata_in_channel";
        }

        //Setup params and execute query
        SelectMode m = ModeFactory.getMode("Package_queries", mode);
        Map params = new HashMap();
        params.put("target_eid", errata.getId().toString());
        params.put("source_cid", cid.toString());

        Map elabParams = new HashMap();
        elabParams.put("org_id", user.getOrg().getId());
        return makeDataResult(params, elabParams, null, m);
    }

    /**
     * Returns a DataResult containing PackageOverview dto's representing the
     * package_ids_in_set query
     * @param user The User
     * @param label The label of the set we want
     * @param pc The page control for the user
     * @return Returns the list of packages whose id's are in the given set
     */
    public static DataResult packageIdsInSet(User user, String label,
                                             PageControl pc) {

        SelectMode m = ModeFactory.getMode("Package_queries",
                "package_ids_in_set");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("set_label", label);

        Map elabs = new HashMap();
        elabs.put("org_id", user.getOrg().getId());

        DataResult dr;
        if (pc != null) {
            dr = makeDataResult(params, elabs, pc, m);
        }
        else {
            //if page control is null, we don't want to elaborate
            dr = m.execute(params);
            dr.setElaborationParams(elabs);
        }
        return dr;

    }

    /**
     * Returns a DataResult containing PackageOverview dto's representing the
     * package_ids_in_set query
     * @param user The User
     * @param label The label of the set we want
     * @return Returns the list of packages whose id's are in the given set
     */
    public static DataResult packageIdsInSet(User user, String label) {

        SelectMode m = ModeFactory.getMode("Package_queries",
                "package_ids_in_set");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        params.put("set_label", label);

        Map<String, Long> elabs = new HashMap<String, Long>();
        elabs.put("org_id", user.getOrg().getId());

        DataResult dr;
        dr = makeDataResult(params, elabs, null, m);
        return dr;

    }

    /**
     * Returns a data result containing PackageOverview dto's representing the
     * packages that are currently associated with this errata.
     * @param errata The errata in question
     * @param pc The page control for the logged in user
     * @return The packages associated with this errata
     */
    public static DataResult packagesInErrata(Errata errata,
                                              PageControl pc) {
        //Get the correct query depending on whether or not this
        //errata is published
        String mode = "packages_in_tmp_errata";
        if (errata.isPublished()) {
            mode = "packages_in_errata";
        }

        SelectMode m = ModeFactory.getMode("Package_queries", mode);

        //setup the params and execute the query
        Map params = new HashMap();
        params.put("eid", errata.getId());
        params.put("org_id", errata.getOrg().getId());
        if (pc != null) {
            return makeDataResult(params, params, pc, m);
        }
        DataResult dr = m.execute(params);
        dr.setTotalSize(dr.size());
        return dr;
    }

    /**
     * Returns true if the package whose name and evr id are passed in exists
     * in the given channel whose id is cid.
     * @param cid Channel id
     * @param evrid package evr id
     * @param nameid package name id
     * @return true if package exists in channel.
     */
    public static boolean isPackageInChannel(Long cid, Long nameid, Long evrid) {
        return PackageFactory.isPackageInChannel(cid, nameid, evrid);
    }

    /**
     * Get the ID of the package that needs updating based on the name.
     *
     * So, if say the server has up2date version 2.8.0 and
     * the latest rev of up2date is 3.1.1 this will return the
     * ID of the package for 3.1.1
     *
     * @param sid of system
     * @param packageName of system - up2date for example
     * @return Long id of package if found.  null if not.
     */
    public static Long getServerNeededUpdatePackageByName(Long sid, String packageName) {
        Map params = new HashMap();
        params.put("sid", sid);
        params.put("name", packageName);
        SelectMode m = ModeFactory.getMode("Package_queries",
                "server_packages_needing_update");
        DataResult dr = m.execute(params);
        if (dr.size() > 0) {
            Long id = (Long) ((Map) dr.get(0)).get("id");
            return new Long(id.longValue());
        }
        else {
            return null;
        }
    }

    /**
     * Find the most up to date package with the given name accessible to a system with
     * the given system id.
     * @param sid The id of a system to which the package must be accessible.
     * @param name The exact name of the package sought for.
     * @return A map with keys 'name_id' and 'evr_id' containing Long types.
     *         Null if nothing found.
     */
    public static Map lookupEvrIdByPackageName(Long sid, String name) {
        Map params = new HashMap();
        params.put("sid", sid);
        params.put("name", name);
        SelectMode m = ModeFactory.getMode("Package_queries",
                "lookup_id_combo_by_name");
        DataResult dr = m.execute(params);
        if (dr.size() > 0) {
            return (Map) dr.get(0);
        }
        else {
            return null;
        }
    }

    /**
     * Lookup a package name.
     * @param name Package name to lookup.
     * @return PackageName associated with the given string name.
     */
    public static PackageName lookupPackageName(String name) {
        Session session = null;
        try {
            session = HibernateFactory.getSession();
            return (PackageName)session.getNamedQuery("PackageName.findByName")
                                       .setString("name", name)
                                       .setCacheable(true)
                                       .uniqueResult();
        }
        catch (HibernateException e) {
            log.error("Hibernate exception: " + e.toString());
        }
        return null;
    }

    /**
     * Get the list of  Package Names that match the passed in capability string.
     *
     * Example:  "rhn.kickstart.boot_image" for the list of auto kickstart rpms
     * @param org making the request
     * @param capabilityName to search for
     * @return DataResult containing *just* the package name strings
     */
    public static DataResult packageNamesByCapability(Org org,
            String capabilityName) {
        Map params = new HashMap();
        params.put("org_id", org.getId());
        params.put("cap_name", capabilityName);
        SelectMode m = ModeFactory.getMode("Package_queries",
                "name_by_provide");
        return m.execute(params);
    }

    /**
     * Get the list of package names that match the passed in capability and channel.
     *
     * @param org making the request
     * @param capabilityName to search for
     * @param chan channel to search for
     * @return DataResult containing *just* the package name strings
     */
    public static DataResult packageNamesByCapabilityAndChannel(Org org,
            String capabilityName, Channel chan) {
        Map params = new HashMap();
        params.put("org_id", org.getId());
        params.put("cap_name", capabilityName);
        params.put("channel_id", chan.getId());
        SelectMode m = ModeFactory.getMode("Package_queries",
                "name_by_provide_and_channel");
        return m.execute(params);
    }

    /**
     * Compares an evr to another evr.
     * @param epoch1 Epoch 1
     * @param version1 Version 1
     * @param release1 Release 1
     * @param epoch2 Epoch 2
     * @param version2 Version 2
     * @param release2 Release 2
     * @return Returns 1 if EVR1 > EVR2, -1 if EVR1 < EVR2, and 0 if EVR1 == EVR2.
     */
    public static int verCmp(String epoch1, String version1, String release1,
                             String epoch2, String version2, String release2) {

        // Compare the Epochs
        int c = compareEpochs(epoch1, epoch2);
        if (c != 0) {
            return c;
        }

        // Compare the Versions
        RpmVersionComparator cmp = new RpmVersionComparator();
        c = cmp.compare(StringUtils.defaultString(version1),
                        StringUtils.defaultString(version2));
        if (c != 0) {
            return c;
        }

        // Compare the Releases
        return cmp.compare(StringUtils.defaultString(release1),
                           StringUtils.defaultString(release2));
    }

    /**
     * Deletes a package from the system
     * @param user calling user
     * @param pkg package to delete
     * @throws PermissionCheckFailureException - caller is not an org admin,
     * the package is in one of the RH owned channels, or is in different org
     */
    public static void schedulePackageRemoval(User user, Package pkg)
        throws PermissionCheckFailureException {
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            throw new PermissionCheckFailureException();
        }
        DataResult channels = PackageManager.orgPackageChannels(
                user.getOrg().getId(), pkg.getId());
        if (pkg.getOrg() == null || user.getOrg() != pkg.getOrg()) {
            throw new PermissionCheckFailureException();
        }
        Session session = HibernateFactory.getSession();
        cleanupFileEntries(pkg.getId());
        StringBuffer packageFileName = new StringBuffer();
        if (pkg.getPath() != null) {
            packageFileName.append(pkg.getPath().trim());
        }
        else if (pkg.getFile() != null) {
            packageFileName.append(pkg.getFile());
        }
        String pfn = packageFileName.toString().trim();
        if (pfn.length() > 0) {
            schedulePackageFileForDeletion(pfn);
        }

        // For every channel the package is in, mark the channel as "changed" in case its
        // metadata needs tto be updated (RHEL5+, mostly)
        for (Iterator itr = channels.iterator(); itr.hasNext();) {
            Map m = (Map)itr.next();
            ChannelManager.queueChannelChange(m.get("label").toString(),
                    "java::deletePackage",
                    pkg.getPackageName().getName());
        }
        session.delete(pkg);
    }

    private static void cleanupFileEntries(Long pid) {
        Map params = new HashMap();
        params.put("pid", pid);
        List excludeSatellite = Arrays.asList(EXCLUDE_SATELLITE);
        for (int x = 0; x < CLEANUP_QUERIES.length; x++) {
            if (excludeSatellite.indexOf(CLEANUP_QUERIES[x]) > -1) {
                continue;
            }
            WriteMode writeMode = ModeFactory.getWriteMode("Package_queries",
                    "cleanup_package_" + CLEANUP_QUERIES[x]);
            writeMode.executeUpdate(params);
        }
    }

    /**
     * Helper method to compare two epoch strings according to the algorithm contained
     * in: modules/rhn/RHN/DB/Package.pm --> sub vercmp
     * @param epoch1 Epoch 1
     * @param epoch2 Epoch 2
     * @return Returns 1 if epoch1 > epoch2, -1 if epoch1 < epoch2,
     * and 0 if epoch1 == epoch2
     */
    private static int compareEpochs(String epoch1, String epoch2) {
        //Trim the epoch strings to null
        epoch1 = StringUtils.trimToNull(epoch1);
        epoch2 = StringUtils.trimToNull(epoch2);

        //Check the epochs
        Integer e1 = null;
        Integer e2 = null;
        if (epoch1 != null && StringUtils.isNumeric(epoch1)) {
            e1 = new Integer(epoch1);
        }
        if (epoch2 != null && StringUtils.isNumeric(epoch2)) {
            e2 = new Integer(epoch2);
        }
        //handle null cases
        if (e1 != null && e2 == null) {
            return 1;
        }
        if (e1 == null && e2 != null) {
            return -1;
        }
        if (e1 == null && e2 == null) {
            return 0;
        }

        // If we made it here, it is safe to do an Integer comparison between the two
        return e1.compareTo(e2);
    }

    private static void schedulePackageFileForDeletion(String fileName) {
        Map params = new HashMap();
        params.put("path", fileName);
        WriteMode wm = ModeFactory.getWriteMode("Package_queries",
                "schedule_pkg_for_delete");
        wm.executeUpdate(params);
    }

    /**
     * Looks at a published errata and a channel and returns a list of PackageComparisons
     * containing the packages that the errata has more recent versions of and may
     * be pushed into the channel by the user
     * @param cid channel id
     * @param eid errata id
     * @param pc PageControl object needed to handle pagination issues.
     * @return DataResult of PackageComparisons
     */
    public static DataResult possiblePackagesForPushingIntoChannel(Long cid, Long eid,
                                                            PageControl pc) {
        Map params = new HashMap();
        params.put("cid", cid);
        params.put("eid", eid);

        SelectMode m1 = ModeFactory.getMode("Package_queries",
                                           "possible_packages_for_pushing_into_channel");

        DataResult possiblePackages = m1.execute(params);

        SelectMode m2 = ModeFactory.getMode("Package_queries",
            "packages_in_errata_not_in_channel");

        DataResult notInChannelPackages = m2.execute(params);
        Iterator i = notInChannelPackages.iterator();

        // Remove packages that are in both queries
        while (i.hasNext()) {
            PackageComparison po = (PackageComparison) i.next();
            for (int x = 0; x < possiblePackages.size(); x++) {
                PackageComparison pinner = (PackageComparison) possiblePackages.get(x);
                if (pinner.getId().equals(po.getId())) {
                    log.debug("possiblePackagesForPushingIntoChannel removing: " +
                            pinner.getId());
                    i.remove();
                }
            }
        }

        // Combine the 2
        possiblePackages.addAll(notInChannelPackages);
        if (log.isDebugEnabled()) {
            log.debug("All: " + possiblePackages);
        }
        possiblePackages.setTotalSize(possiblePackages.size());
        return processPageControl(possiblePackages, pc, null);
    }

    /**
     * Given a server this method returns the redhat-release package.
     * This package is a marker package and holds information like
     * the rhel release and can be futher queried to get the evr information.
     * @param server the server object who has to be queried
     * @return the redhat release package or null if the package can't be found..
     */
    public static InstalledPackage lookupReleasePackageFor(Server server) {
        return PackageFactory.lookupByNameAndServer(REDHAT_RELEASE_PACKAGE, server);
    }

    /**
     * Returns package metadata for all packages named 'packageName' and exist
     * in the channels whose arch is one of the 'channelArches'.
     * @param org The users Org.
     * @param packageName Name of package being sought.
     * @param channelarches list of valid channel arches. i.e.
     * <ul>
     * <li>channel-ia32</li>
     * <li>channel-ia64</li>
     * <li>channel-sparc</li>
     * <li>channel-alpha</li>
     * <li>channel-s390</li>
     * <li>channel-s390x</li>
     * <li>channel-iSeries</li>
     * <li>channel-pSeries</li>
     * <li>channel-x86_64</li>
     * <li>channel-ppc</li>
     * <li>channel-sparc-sun-solaris</li>
     * <li>channel-i386-sun-solaris</li>
     * </ul>
     * @return package metadata for all packages named 'packageName' and exist
     * in the channels whose arch is one of the 'channelArches'.
     */
    public static DataResult lookupPackageNameOverview(
            Org org, String packageName, String[] channelarches) {

        Map params = new HashMap();
        params.put("org_id", org.getId());
        params.put("package_name", packageName);

        List<String> inClause = Arrays.asList(channelarches);

        SelectMode m = ModeFactory.getMode("Package_queries", "packages_by_name");
        return m.execute(params, inClause);
    }

    /**
     * Returns package metadata for all packages named 'packageName' and exist
     * in the channels which which the orgId is subscribed.
     * @param org The users Org.
     * @param packageName Name of package being sought.
     * @return package metadata for all packages named 'packageName' and exist
     * in the channels which which the orgId is subscribed.
     */
    public static DataResult lookupPackageNameOverview(Org org, String packageName) {
        Map params = new HashMap();
        params.put("org_id", org.getId());
        params.put("package_name", packageName);

        if (OrgFactory.getActiveSystems(org) > 0) {
            SelectMode m = ModeFactory.getMode(
                    "Package_queries", "packages_by_name_smart");
            return m.execute(params);
        }
        else {
            SelectMode m = ModeFactory.getMode(
                    "Package_queries", "packages_by_name_clabel");
            return m.execute(params);
        }
    }

    /**
     * Returns package metadata for all packages named 'packageName' and exist
     * in passed in channelID if the ORG has access..
     * @param org The users Org.
     * @param packageName Name of package being sought.
     * @param channelID Id of the channel to lookup package in
     *
     * @return package metadata for all packages named 'packageName' and exist
     * in the channels which which the orgId is subscribed.
     */
    public static DataResult lookupPackageNameOverviewInChannel(Org org, String packageName,
            Long channelID) {
        Map params = new HashMap();
        params.put("org_id", org.getId());
        params.put("package_name", packageName);
        params.put("channel_id", channelID);

        SelectMode m = ModeFactory.getMode(
                "Package_queries", "packages_by_name_cid");
        return m.execute(params);
    }

    /**
     * list patch sets for a specific channel
     * @param cid the channel id
     * @return list of patch sets
     */
    public static DataResult listPatchSetsForChannel(Long cid) {
        Map params = new HashMap();
        params.put("cid", cid);

        SelectMode m = ModeFactory.getMode(
                "Package_queries", "patchsets_in_channel");
        return m.execute(params);

    }

    /**
     * Lookup packages contained in fromCid that are eligable to be put in toCid.
     *      Packages are filtered based on channel/package arch, and excluded if
     *      a package with the same nvrea exists in the toCid
     * @param fromCid channel id to pull packages from
     * @param toCid channel id of channel that you will be pushing packges to (later on)
     * @return DataResult of PackageOverview objects
     */
    public static DataResult lookupPackageForChannelFromChannel(Long fromCid, Long toCid) {
        Map params = new HashMap();
        params.put("cid", toCid);
        params.put("scid", fromCid);

            SelectMode m = ModeFactory.getMode(
                    "Package_queries", "packages_for_channel_from_channel");

            DataResult dr = m.execute(params);
            dr.setElaborationParams(new HashMap());
            return dr;
    }

    /**
     * Lookup custom packages (packages with org_id of the current user) that can
     *      be pushed into the a channel (cid).
     *      Packages are filtered based on channel/package arch, and excluded if
     *      a package with the same nvrea exists in the toCid
     * @param cid channel id of channel that you will be pushing packges to (later on)
     * @param orgId the org of the custom packages
     * @return DataResult of PackageOverview objects
     */
    public static DataResult lookupCustomPackagesForChannel(Long cid, Long orgId) {
        Map params = new HashMap();
        params.put("cid", cid);
        params.put("org_id", orgId);

            SelectMode m = ModeFactory.getMode(
                    "Package_queries", "custom_packages_for_channel");

            DataResult dr = m.execute(params);
            dr.setElaborationParams(new HashMap());
            return dr;
    }

    /**
     * Lookup orphaned custom packages (those that belong to no channel) for insertion
     *      into a channel.  Packages are filtered based on channel/package arch, and
     *      if a package already exists in the channel based of it's nvrea.
     * @param cid the channel to look at for inserting
     * @param orgId the org who owns the packages
     * @return list of PackageOverview objects
     */
    public static DataResult lookupOrphanPackagesForChannel(Long cid, Long orgId) {
        Map params = new HashMap();
        params.put("cid", cid);
        params.put("org_id", orgId);

            SelectMode m = ModeFactory.getMode(
                    "Package_queries", "orphan_packages_for_channel");

            DataResult dr = m.execute(params);
            dr.setElaborationParams(new HashMap());
            return dr;
    }

    /**
     * Add packages to channel whos package_ids are in a set
     * @param user the user doing the pushing
     * @param cid the channel to push packages to
     * @param set the set of packages
     */
    public static void addChannelPackagesFromSet(User user, Long cid, RhnSet set) {
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("cid", cid);
        params.put("set_label", set.getLabel());
        WriteMode writeMode = ModeFactory.getWriteMode("Package_queries",
                "insert_channel_packages_in_set");
        writeMode.executeUpdate(params);
        RhnSetManager.store(set);
    }

    /**
     * List orphaned custom packages for an org
     * @param orgId the org
     * @return list of package overview objects
     */
    public static DataResult listOrphanPackages(Long orgId) {
        Map params = new HashMap();
        params.put("org_id", orgId);

            SelectMode m = ModeFactory.getMode(
                    "Package_queries", "orphan_packages");

            DataResult dr = m.execute(params);
            dr.setElaborationParams(new HashMap());
            return dr;
    }

    /**
     * List all custom  packages for an org
     * @param orgId the org
     * @return List of custom package (PackageOverview)
     */
    public static DataResult listCustomPackages(Long orgId) {
        Map params = new HashMap();
        params.put("org_id", orgId);

            SelectMode m = ModeFactory.getMode(
                    "Package_queries", "all_custom_packages");

            DataResult dr = m.execute(params);
            Map elabs = new HashMap();
            elabs.put("org_id", orgId);
            dr.setElaborationParams(elabs);
            return dr;
    }

    /**
     * list custom packages contained in a channel
     * @param cid the channel id
     * @param orgId the org id
     * @return the list of custom package (package overview)
     */
    public static DataResult listCustomPackageForChannel(Long cid, Long orgId) {
        Map params = new HashMap();
        params.put("org_id", orgId);
        params.put("cid", cid);
            SelectMode m = ModeFactory.getMode(
                    "Package_queries", "custom_package_in_channel");

            DataResult dr = m.execute(params);
            dr.setElaborationParams(new HashMap());
            return dr;
    }

    /**
     * Clear the needed package cache entries for a package
     * @param pid the package id
     */
    public static void clearNeededPackageCache(Long pid) {
        Map params = new HashMap();
        params.put("pid", pid);
            WriteMode m = ModeFactory.getWriteMode("Package_queries",
                    "cleanup_needed_package_cache");
            m.executeUpdate(params);
    }


    /**
     * This deletes a package completely from the satellite including the
     *      physical rpm on the disk
     * @param ids the set of package ids
     * @param user the user doing the deleting
     */
    public static void deletePackages(Set<Long> ids, User user) {

        if (!user.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionException(RoleFactory.CHANNEL_ADMIN);
        }

        long start = System.currentTimeMillis();

        // Stuff the package IDs into an RhnSet that the rest of the queries
        // will work on
        RhnSet set = RhnSetDecl.PACKAGES_TO_REMOVE.create(user);

        for (Long id : ids) {
            set.addElement(id);
        }

        RhnSetManager.store(set);

        // Needed for subsequent queries
        WriteMode mode;
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("set_label", set.getLabel());

        // First, capture all of the channels that have one or more of the packages
        // to delete (we'll need this later)
        SelectMode selectMode = ModeFactory.getMode("Package_queries",
            "determine_channels_for_packages_in_set");

        DataResult dataResult = selectMode.execute(params);
        Set<Map> channelIds = new HashSet<Map>(dataResult);

        // Clear server->package cache for all packages
        mode = ModeFactory.getWriteMode("Package_queries",
            "cleanup_needed_package_cache_from_set");

        mode.executeUpdate(params);


        // Clear server->package cache for all packages
        mode = ModeFactory.getWriteMode("Package_queries",
            "cleanup_package_changelog_from_set");

        mode.executeUpdate(params);

        // Clear server->package cache for all packages
        mode = ModeFactory.getWriteMode("Package_queries",
            "cleanup_package_files_from_set");
        mode.executeUpdate(params);

        // Schedule package files for deletion for all packages
        mode = ModeFactory.getWriteMode("Package_queries",
            "schedule_pkg_for_delete_from_set");

        mode.executeUpdate(params);

        // Delete package sources for all packages
        mode = ModeFactory.getWriteMode("Package_queries",
            "delete_package_sources_from_set");

        mode.executeUpdate(params);

        // Delete link between channel and package
        mode = ModeFactory.getWriteMode("Package_queries",
            "cleanup_package_channels_from_set");

        mode.executeUpdate(params);

        // Delete all packages
        mode = ModeFactory.getWriteMode("Package_queries",
            "delete_packages_from_set");

        mode.executeUpdate(params);

        log.debug("Time to delete [" + ids.size() + "] packages [" +
            (System.currentTimeMillis() - start) + "] ms");

        start = System.currentTimeMillis();

        // For now, continue to use repeated calls to the managers rather than having the
        // calls take place using the data in the package IDs RhnSet
        List<Long> pList = new ArrayList<Long>(ids);
        for (Map channelIdData : channelIds) {
            Long channelId = (Long) channelIdData.get("channel_id");
            ChannelManager.refreshWithNewestPackages(channelId, "web.package_delete");
            ErrataCacheManager.deleteCacheEntriesForChannelPackages(channelId, pList);
        }

        log.debug("Time to update [" + channelIds.size() + "] channels [" +
            (System.currentTimeMillis() - start) + "] ms");
    }

    /**
     * guestimate a package based on channel id, name and evr
     * @param channelId the channel
     * @param nameId the name
     * @param evrId the evr id
     * @param org the org
     * @return first package object found during the search
     */
    public static Package guestimatePackageByChannel(Long channelId, Long nameId,
            Long evrId, Org org) {
        Map params = new HashMap();
        params.put("cid", channelId);
        params.put("nameId", nameId);
        params.put("evrId", evrId);
        SelectMode m = ModeFactory.getMode(
                "Package_queries", "guestimate_package_by_channel");

        DataResult dr = m.execute(params);
        if (dr != null && !dr.isEmpty()) {
            return PackageFactory.lookupByIdAndOrg(
                    (Long) ((Map)dr.get(0)).get("id"), org);
        }

        return null;
    }

    /**
     * guestimate a package based on system id, name and evr
     * @param systemId the channel
     * @param nameId the name
     * @param evrId the evr id
     * @param archId the arch id
     * @param org the org
     * @return first package object found during the search
     */
    public static Package guestimatePackageBySystem(Long systemId, Long nameId,
            Long evrId, Long archId, Org org) {
        SelectMode m;
        Map params = new HashMap();
        params.put("sid", systemId);
        params.put("nameId", nameId);
        params.put("evrId", evrId);

        if (archId != null && archId != 0) {
            params.put("archId", archId);
            m = ModeFactory.getMode(
                    "Package_queries", "guestimate_package_by_system_arch");
        }
        else {
            m = ModeFactory.getMode(
                    "Package_queries", "guestimate_package_by_system");
        }

        DataResult dr = m.execute(params);
        if (dr != null && !dr.isEmpty()) {
            return PackageFactory.lookupByIdAndOrg(
                    (Long) ((Map)dr.get(0)).get("id"), org);
        }

        return null;
    }

    /**
     * Returns the list of packages installed on at least one system in the SSM, along with
     * the count of how many systems each package is installed on.
     *
     * @param user user
     * @return list of {@link com.redhat.rhn.frontend.dto.SsmRemovePackageListItem}
     */
    public static DataResult packagesFromServerSet(User user) {

        SelectMode m = ModeFactory.getMode("Package_queries", "packages_from_server_set");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("set_label", RhnSetDecl.SYSTEMS.getLabel());

        DataResult result = m.execute(params);
        return result;
    }

    /**
     * Returns the list of packages that are on at least one system in the SSM that can
     * be upgraded, along with a count of how many systems each package is installed on.
     *
     * @param user user
     * @return list of {@link com.redhat.rhn.frontend.dto.SsmUpgradablePackageListItem}
     */
    public static DataResult upgradablePackagesFromServerSet(User user) {

        SelectMode m = ModeFactory.getMode("Package_queries", "ssm_packages_for_upgrade");
        Map params = new HashMap();
        params.put("user_id", user.getId());

        DataResult result = m.execute(params);
        return result;
    }

    /**
     * Create all repoentries for a channel's packages if needed
     * @param cid the channel id
     */
    public static void createRepoEntrys(Long cid) {
        Map params = new HashMap();
        params.put("cid", cid);
        WriteMode writeMode = ModeFactory.getWriteMode("Package_queries",
                "create_repo_entrys");
        writeMode.executeUpdate(params);
    }

    private static void updateRepoEntry(Long packageId, String xml, String type) {
        if (!ConfigDefaults.get().useDBRepodata()) {
            return;
        }

        Map params = new HashMap();
        params.put("pid", packageId);
        byte[] bytes = CompressionUtil.gzipCompress(xml);

        params.put("xml", bytes);
        WriteMode writeMode = ModeFactory.getWriteMode("Package_queries",
                "insert_" + type + "_xml");
        writeMode.executeUpdate(params);
    }

    /**
     * Update the primary XML for a package
     * @param packageId the package id
     * @param primaryXml the raw xml
     */
    public static void updateRepoPrimary(Long packageId, String primaryXml) {
        updateRepoEntry(packageId, primaryXml, "primary");
    }

    /**
     *
     * @param packageId the package id
     * @param filelistXml the raw xml
     */
    public static void updateRepoFileList(Long packageId, String filelistXml) {
        updateRepoEntry(packageId, filelistXml, "filelist");
    }

    /**
     *
     * @param packageId the package id
     * @param otherXml the raw xml
     */
    public static void updateRepoOther(Long packageId, String otherXml) {
        updateRepoEntry(packageId, otherXml, "other");
    }


    /**
     * utility method for getting the repodata for a package
     * @param packageId the package id
     * @return A list of package dto objects
     */
    public static DataResult getRepoData(Long packageId) {
        SelectMode m = ModeFactory.getMode("Package_queries", "lookup_repodata");
        Map params = new HashMap();
        params.put("pid", packageId);

        DataResult result = m.execute(params);
        return result;
    }
}
