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
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import redstone.xmlrpc.XmlRpcFault;

import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.frontend.action.BaseSearchAction;
import com.redhat.rhn.frontend.dto.PackageOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.xmlrpc.SearchServerIndexException;
import com.redhat.rhn.manager.channel.ChannelManager;

/**
 * PackageSearchAction
 * @version $Rev$
 */
public class PackageSearchAction extends BaseSearchAction {

    protected ActionForward doExecute(HttpServletRequest request, ActionMapping mapping,
                    DynaActionForm form)
        throws MalformedURLException, XmlRpcFault, SearchServerIndexException {

        RequestContext ctx = new RequestContext(request);
        String searchString = form.getString(SEARCH_STR);
        String viewmode = form.getString(VIEW_MODE);
        Boolean fineGrained = (Boolean) form.get(FINE_GRAINED);
        String searchCriteria = form.getString(WHERE_CRITERIA);
        String[] selectedArches = null;
        Long filterChannelId = null;
        boolean relevantFlag = false;

        // Default to relevant channels if no search criteria was specified
        if (searchCriteria == null || searchCriteria.equals("")) {
            searchCriteria = RELEVANT;
        }

        // Handle the radio button selection for channel filtering
        if (searchCriteria.equals(RELEVANT)) {
            relevantFlag = true;
        }
        else if (searchCriteria.equals(ARCHITECTURE)) {
            /* The search call will function as being scoped to architectures if the arch
               list isn't null. In order to actually get radio-button-like functionality
               we can't rely on the arch list coming in from the form to be null; the
               user may have selected an arch but *not* the radio button for arch. If we
               push off retrieving the arches until we know we want to use them, we can
               get the desired functionality described by the UI.
              */
            selectedArches = form.getStrings(CHANNEL_ARCH);
        }
        else if (searchCriteria.equals(CHANNEL)) {
            String sChannelId = form.getString(CHANNEL_FILTER);
            filterChannelId = Long.parseLong(sChannelId);
        }

        List<Map<String, String>> searchOptions = buildSearchOptions();
        List<Map<String, String>> channelArches = buildChannelArches();

        // Load list of available channels to select as filter
        List allChannels = ChannelManager.allChannelsTree(ctx.getLoggedInUser());

        request.setAttribute(SEARCH_STR, searchString);
        request.setAttribute(VIEW_MODE, viewmode);
        request.setAttribute(SEARCH_OPT, searchOptions);
        request.setAttribute(CHANNEL_ARCHES, channelArches);
        request.setAttribute(CHANNEL_ARCH, selectedArches);
        request.setAttribute(ALL_CHANNELS, allChannels);
        request.setAttribute(CHANNEL_FILTER,
                        form.getString(CHANNEL_FILTER));
        request.setAttribute(RELEVANT, relevantFlag ? "yes" : "no");
        request.setAttribute(FINE_GRAINED, fineGrained);

        // Default where to search criteria
        request.setAttribute(WHERE_CRITERIA, searchCriteria);

        if (!StringUtils.isBlank(searchString)) {
            List<PackageOverview> results =
                    performSearch(ctx, searchString, viewmode, fineGrained, selectedArches,
                            filterChannelId, relevantFlag, searchCriteria);

            request.setAttribute(RequestContext.PAGE_LIST,
                    results != null ? results : Collections.emptyList());
        }
        else {
            request.setAttribute(RequestContext.PAGE_LIST, Collections.emptyList());
        }
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /**
     * Actually do the package-search desired
     * @param ctx incoming request context
     * @param searchString string we're going to search on
     * @param viewmode what kind-of search are we doing?
     * @param fineGrained exact or fuzzy?
     * @param selectedArches do we care about specific arches?
     * @param filterChannelId do we care about a specific channel?
     * @param relevantFlag do we only care about 'relevant to registered profiles"?
     * @param searchCriteria the type of search we are doing
     * @return list of package-overviews found
     * @throws XmlRpcFault bad communication with search server
     * @throws MalformedURLException possibly bad configuration for search server address
     */
    public List<PackageOverview> performSearch(RequestContext ctx, String searchString,
                    String viewmode, Boolean fineGrained, String[] selectedArches,
            Long filterChannelId, boolean relevantFlag, String searchCriteria)
           throws XmlRpcFault, MalformedURLException {
        List<PackageOverview> results =
                PackageSearchHelper.performSearch(ctx.getWebSession().getId(),
                        searchString, viewmode, selectedArches, ctx.getLoggedInUser()
                                .getId(), fineGrained, filterChannelId, searchCriteria);

        // Perform any post-search logic that wasn't done by the search server
        results = removeDuplicateNames(results);
        return results;
    }

    /**
     * Package Search returns a list of all matching packages, this will likely
     * include multiple packages with the same name but different version, release,
     * epoch.  WebUI only wants a list of unique package names, so we need
     * to strip the duplicate names while preserving order.
     *
     * @param pkgs packages returned from search that should be cleaned
     * @return new list object with duplicates removed; does not change the list in place
     */
    private List<PackageOverview> removeDuplicateNames(List<PackageOverview> pkgs) {

        List<PackageOverview> result = new ArrayList<PackageOverview>();
        Set<String> addedNames = new HashSet<String>();
        for (PackageOverview pkgOver : pkgs) {
            if (!addedNames.contains(pkgOver.getPackageName())) {
                addedNames.add(pkgOver.getPackageName());
                result.add(pkgOver);
            }
        }
        return result;
    }

    /**
     * Make sure we have appropriate defaults no matter how we got here
     * Set the defaults (where needed) back into the form so that the rest of the action
     * can find them
     * @param form where we expect values to end up
     */
    protected void insureFormDefaults(HttpServletRequest request,  DynaActionForm form) {
        String searchCriteria = form.getString(WHERE_CRITERIA);
        // Default to relevant channels if no search criteria was specified
        if (searchCriteria == null || searchCriteria.equals("")) {
            form.set(WHERE_CRITERIA, RELEVANT);
        }

        String viewmode = form.getString("view_mode");
        if (viewmode.equals("")) { //first time viewing page
            form.set(VIEW_MODE, OPT_NAME_AND_SUMMARY);
        }

        Boolean fineGrained = (Boolean) form.get(FINE_GRAINED);
        if (fineGrained == null) {
            fineGrained = false;
        }
        if (OPT_FREE_FORM.equals(viewmode)) {
            // adding a boolean of true to signify we want the results to be
            // constrained to closer matches, this will force the Lucene Queries
            // to use a "MUST" instead of the default "SHOULD".  It will not
            // allow fuzzy matches as in spelling errors, but it will allow
            // free form searches to do more advanced options
            fineGrained = true;
        }
        form.set(FINE_GRAINED, fineGrained);
    }

    /**
     * Build the channel-arch-pulldown for all arches that are not in the 'excluded' list
     * @return For each arch, a Map of localized display-name and value
     */
    private List<Map<String, String>> buildChannelArches() {
        List<Map<String, String>> channelArches = new ArrayList<Map<String, String>>();
        List<ChannelArch> arches = ChannelManager.getChannelArchitectures();
        List<String> syncdLabels = ChannelManager.getSyncdChannelArches();
        for (ChannelArch arch : arches) {
            if (!EXCLUDED_ARCHES.contains(arch.getLabel())) {
                // if the label does *NOT* exist, this channel arch has no
                // channels in the database. So we want to flag it.
                addOption(channelArches, arch.getName(), arch.getLabel(),
                        !syncdLabels.contains(arch.getLabel()));
            }
        }
        return channelArches;
    }

    /**
     * Builds the package-search-option pulldown
     * @return For each available option, a Map of localized display-name and value
     */
    private List<Map<String, String>> buildSearchOptions() {
        List<Map<String, String>> searchOptions = new ArrayList<Map<String, String>>();
        // setup the option list for select box (view_mode).
        addOption(searchOptions, "packages.search.free_form", OPT_FREE_FORM);
        addOption(searchOptions, "packages.search.name", OPT_NAME_ONLY);
        addOption(searchOptions, "packages.search.name_and_desc", OPT_NAME_AND_DESC);
        addOption(searchOptions, "packages.search.both", OPT_NAME_AND_SUMMARY);
        return searchOptions;
    }


 }
