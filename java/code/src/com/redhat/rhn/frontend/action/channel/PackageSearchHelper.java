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
package com.redhat.rhn.frontend.action.channel;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.frontend.dto.PackageOverview;
import com.redhat.rhn.frontend.xmlrpc.SearchServerIndexException;
import com.redhat.rhn.manager.channel.ChannelManager;

import org.apache.log4j.Logger;

import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;

import redstone.xmlrpc.XmlRpcClient;
import redstone.xmlrpc.XmlRpcFault;
      
/**
 * PackageSearchHelper
 * @version $Rev$
 */
public class PackageSearchHelper {
    private static Logger log = Logger.getLogger(PackageSearchHelper.class);

    public static final String OPT_FREE_FORM = "search_free_form";
    public static final String OPT_NAME_AND_DESC = "search_name_and_description";
    public static final String OPT_NAME_AND_SUMMARY = "search_name_and_summary";
    public static final String OPT_NAME_ONLY = "search_name";

    private PackageSearchHelper() {
    }
    
    /**
     * Will form a search request and send message to search server
     *
     * @param sessionId session id
     * @param searchString search string
     * @param mode mode as in name only, name description, name and summary, free form
     * @param selectedArches list of archs
     * @return List of PackageOverview objects
     * @throws XmlRpcFault bad communication with search server
     * @throws MalformedURLException possibly bad configuration for search server address
     * @throws SearchServerIndexException error executing query
     */
    public static List<PackageOverview> performSearch(Long sessionId, String searchString,
                               String mode, String[] selectedArches)
        throws XmlRpcFault, MalformedURLException, SearchServerIndexException {
        return performSearch(sessionId, searchString, mode, selectedArches, true);
    }

    /**
     * Will form a search request and send message to search server
     * 
     * @param sessionId session id
     * @param searchString search string
     * @param mode mode as in name only, name description, name and summary, free form
     * @param selectedArches list of archs
     * @param relevantFlag if set will force packages returned to be relevant to
     *  subscribed channels
     * @return List of PackageOverview objects
     * @throws XmlRpcFault bad communication with search server
     * @throws MalformedURLException possibly bad configuration for search server address
     * @throws SearchServerIndexException error executing query
     */
    public static List<PackageOverview> performSearch(Long sessionId, String searchString,
                               String mode, String[] selectedArches, boolean relevantFlag)
        throws XmlRpcFault, MalformedURLException, SearchServerIndexException {

        log.warn("Performing pkg search: " + searchString + ", " + mode);

        List<String> pkgArchLabels = null;
        if (selectedArches != null) {
            pkgArchLabels = ChannelManager.listCompatiblePackageArches(selectedArches);
        }

        // call search server
        XmlRpcClient client = new XmlRpcClient(
                ConfigDefaults.get().getSearchServerUrl(), true);
        List args = new ArrayList();
        args.add(sessionId);
        args.add("package");
        args.add(preprocessSearchString(searchString, mode, pkgArchLabels));
        Boolean freeFormSearch = false;
        if (OPT_FREE_FORM.equals(mode)) {
            // adding a boolean of true to signify we want the results to be
            // constrained to closer matches, this will force the Lucene Queries
            // to use a "MUST" instead of the default "SHOULD".  It will not
            // allow fuzzy matches as in spelling errors, but it will allow
            // free form searches to do more advanced options
            freeFormSearch = true;
        }
        args.add(freeFormSearch);
        List results = (List)client.invoke("index.search", args);

        if (log.isDebugEnabled()) {
            log.debug("results = [" + results + "]");
        }

        if (results.isEmpty()) {
            return Collections.EMPTY_LIST;
        }

        // need to make the search server results usable by database
        // so we can get the actual results we are to display to the user.
        // also save the items into a Map for lookup later.
        
        List<Long> pids = new ArrayList<Long>();
        Map<String, Integer> lookupmap = new HashMap<String, Integer>();
        // do it in reverse because the search server can return more than one
        // record for a given package name, but that means if we don't go
        // in reverse we risk getting the wrong rank in the lookupmap.
        // for example, [{id:125,name:gtk},{id:127,name:gtk}{id:200,name:kernel}]
        // if we go forward we end up with gtk:1 and kernel:2 but we wanted
        // kernel:2, gtk:0.
        for (int x = results.size() - 1; x >= 0; x--) {
            Map item = (Map) results.get(x);
            lookupmap.put((String)item.get("name"), x);
            Long pid = new Long((String)item.get("id"));
            pids.add(pid);
        }
        
        // The database does not maintain the order of the where clause.
        // In order to maintain the ranking from the search server, we
        // need to reorder the database results to match. This will lead
        // to a better user experience.

        ArrayList<String> arList = null;
        if (selectedArches != null) {
            arList = new ArrayList<String>(Arrays.asList(selectedArches));
        }
        List<PackageOverview> unsorted =
            ChannelManager.packageSearch(pids, arList, relevantFlag);
        List<PackageOverview> ordered = new LinkedList<PackageOverview>();
        
        // we need to use the package names to determine the mapping order
        // because the id in PackageOverview is that of a PackageName while
        // the id from the search server is the Package id.
        for (PackageOverview po : unsorted) {
            Object objIdx = lookupmap.get(po.getPackageName());
            if (objIdx == null) {
                // We got an error looking up a package name, it is most likely caused
                // by the search server giving us data which doesn't map into what is
                // in our database.  This could happen if the search indexes are formed
                // for a different database instance.
                throw new SearchServerIndexException();
            }
            int idx = (Integer)objIdx;
            if (ordered.isEmpty()) {
                ordered.add(po);
                continue;
            }

            boolean added = false;
            for (ListIterator itr = ordered.listIterator(); itr.hasNext();) {
                PackageOverview curpo = (PackageOverview) itr.next();
                int curidx = lookupmap.get(curpo.getPackageName());
                if (idx <= curidx) {
                    itr.previous();
                    itr.add(po);
                    added = true;
                    break;
                }
            }
            
            if (!added) {
                ordered.add(po);
            }
        }

        return ordered;
    }
    
    private static String preprocessSearchString(String searchstring,
                                          String mode,
                                          List<String> arches) {

        if (!OPT_FREE_FORM.equals(mode) && searchstring.indexOf(':') > 0) {
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
        if (OPT_NAME_AND_SUMMARY.equals(mode)) {
            return "(name:(" + query + ")^2 summary:(" + query +
                   ") filename:(" + query + "))" + archBuf.toString();
        }
        else if (OPT_NAME_AND_DESC.equals(mode)) {
            return "(name:(" + query + ")^2 description:(" + query +
                   ") filename:(" + query + "))" + archBuf.toString();
        }
        else if (OPT_NAME_ONLY.equals(mode)) {
            return "(name:(" + query + ")^2 filename:(" + query + "))" +
                   archBuf.toString();
        }
        // OPT_FREE_FORM send as is.
        return buf.toString();
    }
}
