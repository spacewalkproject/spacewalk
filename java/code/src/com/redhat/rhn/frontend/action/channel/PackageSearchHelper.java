/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.channel;

import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.log4j.Logger;

import redstone.xmlrpc.XmlRpcClient;
import redstone.xmlrpc.XmlRpcFault;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.frontend.action.BaseSearchAction;
import com.redhat.rhn.frontend.dto.PackageOverview;
import com.redhat.rhn.frontend.xmlrpc.SearchServerIndexException;
import com.redhat.rhn.manager.channel.ChannelManager;

/**
 * PackageSearchHelper
 * @version $Rev$
 */
public class PackageSearchHelper {
    private static Logger log = Logger.getLogger(PackageSearchHelper.class);

    private PackageSearchHelper() {
    }

    /**
     * Will form a search request and send message to search server
     *
     * @param sessionId session id
     * @param searchString search string
     * @param mode mode as in name only, name description, name and summary, free form
     * @param selectedArches list of archs
     * @param relevantUserId user id to filter by if relevant or architecture search
     *   server the user can see is subscribed to
     * @param fineGrained fine grained search
     * @param filterChannelId channel id to filter by if channel search
     * @param searchType type of search to do, one of "relevant", "channel",
     *   "architecture", or "all"
     * @return List of PackageOverview objects
     * @throws XmlRpcFault bad communication with search server
     * @throws MalformedURLException possibly bad configuration for search server address
     * @throws SearchServerIndexException error executing query
     */
    public static List<PackageOverview> performSearch(Long sessionId, String searchString,
            String mode, String[] selectedArches, Long relevantUserId, Boolean fineGrained,
            Long filterChannelId, String searchType) throws XmlRpcFault,
            MalformedURLException, SearchServerIndexException {

        log.info("Performing pkg search: " + searchString + ", " + mode);

        List<String> pkgArchLabels = null;
        if (selectedArches != null) {
            pkgArchLabels = ChannelManager.listCompatiblePackageArches(selectedArches);
        }

        // call search server
        XmlRpcClient client = new XmlRpcClient(
                ConfigDefaults.get().getSearchServerUrl(), true);
        List<Object> args = new ArrayList<Object>();
        args.add(sessionId);
        args.add("package");
        args.add(preprocessSearchString(searchString, mode, pkgArchLabels));
        args.add(fineGrained);
        List results = (List)client.invoke("index.search", args);

        if (log.isDebugEnabled()) {
            log.debug("results = [" + results + "]");
        }

        if (results.isEmpty()) {
            return Collections.emptyList();
        }

        // need to make the search server results usable by database
        // so we can get the actual results we are to display to the user.
        // also save the names into a Set for later.

        List<Long> pids = new ArrayList<Long>();
        Set<String> names = new HashSet<String>();
        for (Object itemObject : results) {
            Map item = (Map) itemObject;
            names.add((String) item.get("name"));
            Long pid = new Long((String)item.get("id"));
            pids.add(pid);
        }

        List<String> arList = null;
        if (selectedArches != null) {
            arList = Arrays.asList(selectedArches);
        }

        // The database does not maintain the order of the where clause.
        // In order to maintain the ranking from the search server, we
        // need to reorder the database results to match. This will lead
        // to a better user experience.

        List<PackageOverview> unsorted =
                PackageFactory.packageSearch(pids, arList, relevantUserId, filterChannelId,
                        searchType);
        List<PackageOverview> ordered = new ArrayList<PackageOverview>();

        Map<String, PackageOverview> nameToPackageMap =
                new HashMap<String, PackageOverview>();
        Set<String> alreadyAddedNames = new HashSet<String>();

        // we need to be able to look up the PackageOverview by its name
        for (PackageOverview po : unsorted) {
            nameToPackageMap.put(po.getPackageName(), po);
        }

        // We got an error looking up a package name, it is most likely caused
        // by the search server giving us data which doesn't map into what is
        // in our database.  This could happen if the search indexes are formed
        // for a different database instance.
        if (!names.containsAll(nameToPackageMap.keySet())) {
            throw new SearchServerIndexException();
        }

        // Iterate through in the order that the search server returned, add packages
        // to the return list in the order they appear in the search results.
        for (Object resultObject : results) {
            Map result = (Map) resultObject;
            String name = (String) result.get("name");
            if (!alreadyAddedNames.contains(name) &&
                    nameToPackageMap.keySet().contains(name)) {
                ordered.add(nameToPackageMap.get(name));
                alreadyAddedNames.add(name);
            }
        }

        return ordered;
    }

    private static String preprocessSearchString(String searchstring,
                                          String mode,
                                          List<String> arches) {

        if (!BaseSearchAction.OPT_FREE_FORM.equals(mode) && searchstring.indexOf(':') > 0) {
            throw new ValidatorException("Can't use free form and field search.");
        }

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

        // if we're passing in arches let's add them to the query
        StringBuffer archBuf = new StringBuffer();
        if (arches != null && !arches.isEmpty()) {
            archBuf.append(" AND (");
            for (String s : arches) {
                archBuf.append("arch:");
                archBuf.append(s);
                archBuf.append(" ");
            }
            archBuf.append(")");
        }
        String query = buf.toString().trim();
        // when searching the name field, we also want to include the filename
        // field in case the user passed in version number.
        if (BaseSearchAction.OPT_NAME_AND_SUMMARY.equals(mode)) {
            return "(name:(" + query + ")^2 summary:(" + query +
                   ") filename:(" + query + "))" + archBuf.toString();
        }
        else if (BaseSearchAction.OPT_NAME_AND_DESC.equals(mode)) {
            return "(name:(" + query + ")^2 description:(" + query +
                   ") filename:(" + query + "))" + archBuf.toString();
        }
        else if (BaseSearchAction.OPT_NAME_ONLY.equals(mode)) {
            return "(name:(" + query + ")^2 filename:(" + query + "))" +
                   archBuf.toString();
        }
        // OPT_FREE_FORM send as is.
        return buf.toString();
    }
}
