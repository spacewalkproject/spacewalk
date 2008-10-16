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
package com.redhat.rhn.frontend.action.systems;


import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.dto.SystemSearchResult;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.log4j.Logger;

import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import redstone.xmlrpc.XmlRpcClient;
import redstone.xmlrpc.XmlRpcFault;

/**
 * SystemSearchHelper
 * This will make calls to the XMLRPC Search Server
 * @version $Rev: 1 $
 */
public class SystemSearchHelper {
    private static Logger log = Logger.getLogger(SystemSearchHelper.class);

    /**
     * These vars store the name of a lucene index on the search server
     */
    public static final String PACKAGES_INDEX = "package";
    public static final String SERVER_INDEX = "server";
    public static final String HARDWARE_DEVICE_INDEX = "hwdevice";
    public static final String SNAPSHOT_TAG_INDEX = "snapshotTag";
    public static final String SERVER_CUSTOM_INFO_INDEX = "serverCustomInfo";
    public static final Double PACKAGE_SCORE_THRESHOLD = 0.5;

    protected SystemSearchHelper() { };

    /**
     * Returns a DataResult of SystemSearchResults which are based on the user's search
     * criteria
     * @param ctx request context
     * @param searchString string to search on
     * @param viewMode what field to search
     * @param invertResults whether the results should be inverted
     * @param whereToSearch whether to search through all user visible systems or the
     *        systems selected in the SSM
     * @return DataResult of SystemSearchResults based on user's search criteria
     * @throws XmlRpcFault on xmlrpc error
     * @throws MalformedURLException on bad search server address
     */
    public static DataResult systemSearch(RequestContext ctx,
                                          String searchString,
                                          String viewMode,
                                          Boolean invertResults,
                                          String whereToSearch)
        throws XmlRpcFault, MalformedURLException {

        /** TODO:
         1) Handle invertResults
         2) Handle whereToSearch
         */

        /**
         * Determine what index to search and form the query
         */
        Map<String, String> params = preprocessSearchString(searchString, viewMode);
        String query = (String)params.get("query");
        String index = (String)params.get("index");
        Long sessionId = ctx.getWebSession().getId();
        /**
         * Contact the XMLRPC search server and get back the results
         */
        List results = performSearch(sessionId, index, query);
        /**
         * We need to translate these results into a fleshed out DTO object which
         * can be displayed.by the JSP
         */
        Map serverIds = null;
        if (PACKAGES_INDEX.equals(index)) {
            serverIds = getResultMapFromPackagesIndex(ctx, results, viewMode);
        }
        else if (SERVER_INDEX.equals(index)) {
            serverIds = getResultMapFromServerIndex(results);
        }
        else if (HARDWARE_DEVICE_INDEX.equals(index)) {
            serverIds = getResultMapFromHardwareDeviceIndex(results);
        }
        else if (SNAPSHOT_TAG_INDEX.equals(index)) {
            serverIds = getResultMapFromSnapshotTagIndex(results);
        }
        else if (SERVER_CUSTOM_INFO_INDEX.equals(index)) {
            serverIds = getResultMapFromServerCustomInfoIndex(results);
        }
        else {
            log.warn("Unknown index: " + index);
            log.warn("Defaulting to treating this as a " + SERVER_INDEX + " index");
            serverIds = getResultMapFromServerIndex(results);
        }
        DataResult retval = processResultMap(ctx.getCurrentUser(), serverIds);
        return retval;
    }

    protected static List performSearch(Long sessionId, String index, String query)
            throws XmlRpcFault, MalformedURLException {

        log.info("Performing system search: index = " + index + ", query = " +
                query);
        XmlRpcClient client = new XmlRpcClient(Config.get().getSearchServerUrl(), true);
        List args = new ArrayList();
        args.add(sessionId);
        args.add(index);
        args.add(query);
        List results = (List)client.invoke("index.search", args);
        if (log.isDebugEnabled()) {
            log.debug("results = [" + results + "]");
        }
        if (results.isEmpty()) {
            return Collections.EMPTY_LIST;
        }
        return results;
    }

    protected static Map<String, String> preprocessSearchString(String searchstring,
                       String mode) {
        StringBuffer buf = new StringBuffer(searchstring.length());
        String[] tokens = searchstring.split(" ");
        for (String s : tokens) {
            if (s.trim().equalsIgnoreCase("AND") ||
                    s.trim().equalsIgnoreCase("OR") ||
                    s.trim().equalsIgnoreCase("NOT")) {
                s = s.toUpperCase();
            }
            buf.append(s);
            buf.append(" ");
        }

        String terms = buf.toString().trim();
        String query;
        String index;

        if (SystemSearchSetupAction.NAME_AND_DESCRIPTION.equals(mode)) {
            query = "name:(" + terms + ") description:(" + terms + ")";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.ID.equals(mode)) {
            query = "id:(" + terms + ")";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.CUSTOM_INFO.equals(mode)) {
            query = "value:(" + terms + ")";
            index = SERVER_CUSTOM_INFO_INDEX;
        }
        else if (SystemSearchSetupAction.SNAPSHOT_TAG.equals(mode)) {
            query = "name:(" + terms + ")";
            index = SNAPSHOT_TAG_INDEX;
        }
        else if (SystemSearchSetupAction.CHECKIN.equals(mode)) {
            Integer numDays = Integer.parseInt(terms);
            Calendar startDate = Calendar.getInstance();
            startDate.add(Calendar.DATE, -1 * numDays);
            query = "checkin:[\"" + formatDateString(new Date(0)) +
            "\" TO \"" + formatDateString(startDate.getTime()) + "\"]";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.REGISTERED.equals(mode)) {
            Integer numDays = Integer.parseInt(terms);
            Calendar startDate = Calendar.getInstance();
            startDate.add(Calendar.DATE, -1 * numDays);
            query = "registered:[\"" + formatDateString(startDate.getTime()) +
            "\" TO \"" + formatDateString(Calendar.getInstance().getTime()) + "\"]";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.CPU_MODEL.equals(mode)) {
            query = "cpuModel:(" + terms + ")";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.CPU_MHZ_LT.equals(mode)) {
            query = "cpuMhz:[0 TO " + terms + "]";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.CPU_MHZ_GT.equals(mode)) {
            query = "cpuMhz:[" + terms + " TO " + Long.MAX_VALUE + "]";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.NUM_CPUS_LT.equals(mode)) {
            query = "cpuNumberOfCpus:{0 TO " + terms + "}";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.NUM_CPUS_GT.equals(mode)) {
            query = "cpuNumberOfCpus:{" + terms + " TO " + Long.MAX_VALUE + "}";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.RAM_LT.equals(mode)) {
            query = "ram:{0 TO " + terms + "}";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.RAM_GT.equals(mode)) {
            query = "ram:{" + terms + " TO " + Long.MAX_VALUE + "}";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.HW_DESCRIPTION.equals(mode)) {
            query = "description:(" + terms + ")";
            index = HARDWARE_DEVICE_INDEX;
        }
        else if (SystemSearchSetupAction.HW_DRIVER.equals(mode)) {
            query = "driver:(" + terms + ")";
            index = HARDWARE_DEVICE_INDEX;
        }
        else if (SystemSearchSetupAction.HW_DEVICE_ID.equals(mode)) {
            query = "deviceId:(" + terms + ")";
            index = HARDWARE_DEVICE_INDEX;
        }
        else if (SystemSearchSetupAction.HW_VENDOR_ID.equals(mode)) {
            query = "vendorId:(" + terms + ")";
            index = HARDWARE_DEVICE_INDEX;
        }
        else if (SystemSearchSetupAction.DMI_SYSTEM.equals(mode)) {
            query = "dmiSystem:(" + terms + ")";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.DMI_BIOS.equals(mode)) {
            query = "dmiBiosVendor:(" + terms + ") dmiBiosVersion:(" + terms + ")" +
                "dmiBiosRelease:(" + terms + ")";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.DMI_ASSET.equals(mode)) {
            query = "dmiAsset:(" + terms + ")";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.HOSTNAME.equals(mode)) {
            query = "hostname:(" + terms + ")";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.IP.equals(mode)) {
            query = "ipaddr:(" + terms + ")";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.INSTALLED_PACKAGES.equals(mode)) {
            query = "name:(" + terms + ")" + " filename:(" + terms + ")";
            index = PACKAGES_INDEX;
        }
        else if (SystemSearchSetupAction.NEEDED_PACKAGES.equals(mode)) {
            query = "name:(" + terms + ")" + " filename:(" + terms + ")";
            index = PACKAGES_INDEX;
        }
        else if (SystemSearchSetupAction.LOC_ADDRESS.equals(mode)) {
            query = "address1:(" + terms + ") address2:(" + terms + ")";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.LOC_BUILDING.equals(mode)) {
            query = "building:(" + terms + ")";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.LOC_ROOM.equals(mode)) {
            query = "room:(" + terms + ")";
            index = SERVER_INDEX;
        }
        else if (SystemSearchSetupAction.LOC_RACK.equals(mode)) {
            query = "rack:(" + terms + ")";
            index = SERVER_INDEX;
        }
        else {
            throw new ValidatorException("Mode: " + mode + " not supported.");
        }

        Map<String, String> retval = new HashMap<String, String>();
        retval.put("query", query);
        retval.put("index", index);
        return retval;
    }

    /**
     * We did a normal package search and got back a List of results for 
     * the package name(s), now we correlate that to what systems have those 
     * installed, or need them to be updated.
     * 
     * TODO:  Look into a quicker/more efficient implementation.  This appears to
     * work....but I think it can be become quicker.
     */
    protected static Map getResultMapFromPackagesIndex(RequestContext ctx, 
            List searchResults, String viewMode) {
        // this is our main result Map which we will return, it's keys
        // represent the list of server Ids this search yielded
        Map serverMaps = new HashMap();
        User user = ctx.getCurrentUser();
        for (Object obj : searchResults) {
            Map result = (Map)obj;
            Map pkgItem = new HashMap();
            pkgItem.put("rank", result.get("rank"));
            pkgItem.put("score", result.get("score"));
            pkgItem.put("name", result.get("name"));
            pkgItem.put("pkgId", result.get("id"));
            
            /** 
             * Dropping results which have a weak score
             */
            if ((Double)result.get("score") < PACKAGE_SCORE_THRESHOLD) {
                log.info("SystemSearchHelper.getResultMapFromPackagesIndex() " +
                        " skipping result<" + result.get("name") + "> score = " +
                        result.get("score") + " it is below threshold: " +
                        PACKAGE_SCORE_THRESHOLD);
                continue;
            }
            Long pkgId = Long.valueOf((String)result.get("id"));
            Package pkg = PackageFactory.lookupByIdAndUser(pkgId, user);
            if (pkg == null) {
                log.warn("SystemSearchHelper.getResultMapFromPackagesIndex() " +
                        " problem when looking up package id <" + pkgId + 
                        " PackageFactory.lookupByIdAndUser returned null.");
                continue;
            }
            List<Long> serverIds = null;
            if (SystemSearchSetupAction.INSTALLED_PACKAGES.equals(viewMode)) {
                serverIds = getSystemsByInstalledPackageId(user, pkgId);
            }
            if (SystemSearchSetupAction.NEEDED_PACKAGES.equals(viewMode)) {
                serverIds = getSystemsByNeededPackageId(user, pkgId);
            }
            for (Long s : serverIds) {
                if (serverMaps.containsKey(s)) {
                    Map m = (Map)serverMaps.get(s);
                    Double score = (Double)result.get("score");
                    if (score > (Double)m.get("score")) {
                        m.put("score", score);
                        m.put("packageName", pkg.getNameEvra());
                    }
                }
                else {
                    // Create the serverInfo which we will be returning back
                    Map serverInfo = new HashMap();
                    serverInfo.put("score", result.get("score"));
                    serverInfo.put("matchingField", "packageName");
                    serverInfo.put("packageName", pkg.getNameEvra());
                    serverMaps.put(s, serverInfo);
                    if (log.isDebugEnabled()) {
                        log.debug("created new map for server id: " + s +
                                ", searched with packageName: " + pkg.getNameEvra() +
                                " score = " + serverInfo.get("score"));
                    }
                }
            } // end for looping over servers per packageId
        } // end looping over packageId
        return serverMaps;
    }

    protected static Map getResultMapFromServerIndex(List searchResults) {
        if (log.isDebugEnabled()) {
            log.debug("forming results for: " + searchResults);
        }
        Map serverIds = new HashMap();
        for (Object obj : searchResults) {
            Map result = (Map)obj;
            Map serverItem = new HashMap();
            serverItem.put("rank", result.get("rank"));
            serverItem.put("score", result.get("score"));
            serverItem.put("name", result.get("name"));
            String matchingField = (String)result.get("matchingField");
            if (matchingField.length() == 0) {
                matchingField = (String)result.get("name");
            }
            serverItem.put("matchingField", matchingField);
            if (log.isDebugEnabled()) {
                log.debug("creating new map for system id: " + result.get("id") +
                        " new map = " + serverItem);
            }
            serverIds.put(Long.valueOf((String)result.get("id")), serverItem);
        }
        return serverIds;
    }

    protected static Map getResultMapFromHardwareDeviceIndex(List searchResults) {
        if (log.isDebugEnabled()) {
            log.debug("forming results for: " + searchResults);
        }
        Map serverIds = new HashMap();
        for (Object obj : searchResults) {
            Map result = (Map)obj;
            Map serverItem = new HashMap();
            serverItem.put("rank", result.get("rank"));
            serverItem.put("score", result.get("score"));
            serverItem.put("name", result.get("name"));
            serverItem.put("hwdeviceId", result.get("id"));
            String matchingField = (String)result.get("matchingField");
            if (matchingField.length() == 0) {
                matchingField = (String)result.get("name");
            }
            serverItem.put("matchingField", matchingField);
            if (log.isDebugEnabled()) {
                log.debug("creating new map for serverId = " + result.get("serverId") +
                        ", hwdevice id: " + result.get("id") + " new map = " +
                        serverItem);
            }
            serverIds.put(Long.valueOf((String)result.get("serverId")), serverItem);
        }
        return serverIds;
    }

    protected static Map getResultMapFromSnapshotTagIndex(List searchResults) {
        if (log.isDebugEnabled()) {
            log.debug("forming results for: " + searchResults);
        }
        Map serverIds = new HashMap();
        for (Object obj : searchResults) {
            Map result = (Map)obj;
            Map serverItem = new HashMap();
            serverItem.put("rank", result.get("rank"));
            serverItem.put("score", result.get("score"));
            serverItem.put("name", result.get("name"));
            serverItem.put("snapshotId", result.get("snapshotId"));
            String matchingField = (String)result.get("matchingField");
            if (matchingField.length() == 0) {
                matchingField = (String)result.get("name");
            }
            serverItem.put("matchingField", matchingField);
            if (log.isDebugEnabled()) {
                log.debug("creating new map for serverId = " + result.get("serverId") +
                        ", snapshotID: " + result.get("snapshotId") + " new map = " +
                        serverItem);
            }
            serverIds.put(Long.valueOf((String)result.get("serverId")), serverItem);
        }
        return serverIds;
    }

    protected static Map getResultMapFromServerCustomInfoIndex(List searchResults) {
        if (log.isDebugEnabled()) {
            log.debug("forming results for: " + searchResults);
        }
        Map serverIds = new HashMap();
        for (Object obj : searchResults) {
            Map result = (Map)obj;
            Map serverItem = new HashMap();
            serverItem.put("rank", result.get("rank"));
            serverItem.put("score", result.get("score"));
            serverItem.put("name", result.get("value"));
            serverItem.put("snapshotId", result.get("snapshotId"));
            String matchingField = (String)result.get("matchingField");
            if (matchingField.length() == 0) {
                matchingField = (String)result.get("value");
            }
            serverItem.put("matchingField", matchingField);
            if (log.isDebugEnabled()) {
                log.debug("creating new map for serverId = " + result.get("serverId") +
                        ", customValueID: " + result.get("id") + " new map = " +
                        serverItem);
            }
            serverIds.put(Long.valueOf((String)result.get("serverId")), serverItem);
        }
        return serverIds;
    }

    protected static DataResult processResultMap(User userIn, Map serverIds) {
        DataResult<SystemSearchResult> serverList =
            UserManager.visibleSystemsAsDtoFromList(userIn,
                    new ArrayList(serverIds.keySet()));
        if (serverList == null) {
            return null;
        }
        for (SystemSearchResult sr : serverList) {
            Map details = (Map)serverIds.get(sr.getId());
            String field = (String)details.get("matchingField");
            sr.setMatchingField(field);
            if (details.containsKey("packageName")) {
                sr.setPackageName((String)details.get("packageName"));
            }
        }
        if (log.isDebugEnabled()) {
            log.debug("sorting server data based on score from lucene search");
        }
        SearchResultScoreComparator scoreComparator =
            new SearchResultScoreComparator(serverIds);
        Collections.sort(serverList, scoreComparator);
        if (log.isDebugEnabled()) {
            log.debug("sorted server data = " + serverList);
        }
        return serverList;
    }
    
    protected static List<Long> getSystemsByInstalledPackageId(User user, Long pkgId) {
        List serverIds = new ArrayList<Long>();
        List<SystemOverview> data = SystemManager.listSystemsWithPackage(user, pkgId);
        if (data == null) {
            log.info("SystemSearchHelper.getSystemsByInstalledPackageId(" + pkgId + 
                    ") got back null.");
            return null;
        }
        log.info("Got back a list of " + data.size() + " SystemOverview objects for " + 
                " SystemManager.listSystemsWithPackage(" + pkgId + ")"); 
        for (SystemOverview so : data) {
            serverIds.add(so.getId());
        }
        return serverIds;
    }
    
    protected static List<Long> getSystemsByNeededPackageId(User user, Long pkgId) {
        List serverIds = new ArrayList<Long>();
        List<SystemOverview> data = SystemManager.listSystemsWithNeededPackage(user, pkgId);
        if (data == null) {
            log.info("SystemSearchHelper.getSystemsByNeededPackageId(" + pkgId + 
                    ") got back null.");
            return null;
        }
        log.info("Got back a list of " + data.size() + " SystemOverview objects for " + 
                " SystemManager.listSystemsWithNeededPackage(" + pkgId + ")"); 
        for (SystemOverview so : data) {
            serverIds.add(so.getId());
        }
        return serverIds;
    }
    
    protected static String formatDateString(Date d) {
        String dateFormat = "MM/dd/yyyy";
        java.text.SimpleDateFormat sdf =
              new java.text.SimpleDateFormat(dateFormat);
        return sdf.format(d);
    }
    /**
     * Will compare two SystemOverview objects based on their score from a lucene search
     * Creates a list ordered from highest score to lowest
     */
    public static class SearchResultScoreComparator implements Comparator {

        protected Map results;
        /**
         * @param resultsIn map of server related info to use for comparisons
         */
        public SearchResultScoreComparator(Map resultsIn) {
            this.results = resultsIn;
        }
        /**
         * @param o1 systemOverview11
         * @param o2 systemOverview2
         * @return comparison info based on lucene score
         */
        public int compare(Object o1, Object o2) {
            Long serverId1 = ((SystemOverview)o1).getId();
            Long serverId2 = ((SystemOverview)o2).getId();
            Double score1 = (Double)((Map)(results.get(serverId1))).get("score");
            Double score2 = (Double)((Map)(results.get(serverId2))).get("score");
            /*
             * Note:  We want a list which goes from highest score to lowest score,
             * so we are reversing the order of comparison.
             */
            return score2.compareTo(score1);
     }
   }
}
