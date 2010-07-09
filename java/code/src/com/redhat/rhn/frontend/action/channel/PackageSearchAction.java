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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PackageDto;
import com.redhat.rhn.frontend.dto.PackageOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.xmlrpc.SearchServerIndexException;
import com.redhat.rhn.manager.channel.ChannelManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcFault;

/**
 * PackageSearchAction
 * @version $Rev$
 */
public class PackageSearchAction extends RhnAction {
    private static Logger log = Logger.getLogger(PackageSearchAction.class);
    /** List of channel arches we don't really support any more. */
    private static final String[] EXCLUDE_ARCH_LABELS = {"channel-sparc",
                                                         "channel-alpha",
                                                         "channel-iSeries",
                                                         "channel-pSeries"};
    public static final String WHERE_CRITERIA = "whereCriteria";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {

        ActionErrors errors = new ActionErrors();
        DynaActionForm form = (DynaActionForm)formIn;
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        Map forwardParams = makeParamMap(request);
        String searchString = request.getParameter("search_string");
        String viewMode = form.getString("view_mode");
        String[] channelArches = form.getStrings("channel_arch");

        try {
            // handle setup, the submission setups the searchstring below
            // and redirects to this page which then performs the search.
            if (!isSubmitted(form)) {
                setupForm(request, form);
                return getStrutsDelegate().forwardParams(
                        mapping.findForward("default"),
                        request.getParameterMap());
            }
        }
        catch (XmlRpcException xre) {
            log.error("Could not connect to search server.", xre);
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("packages.search.connection_error"));
        }
        catch (XmlRpcFault e) {
            log.info("Caught Exception :" + e);
            log.info("ErrorCode = " + e.getErrorCode());
            e.printStackTrace();
            if (e.getErrorCode() == 100) {
                log.error("Invalid search query", e);
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("packages.search.could_not_parse_query",
                                          searchString));
            }
            else if (e.getErrorCode() == 200) {
                log.error("Index files appear to be missing: ", e);
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("packages.search.index_files_missing",
                                          searchString));
            }
            else {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("packages.search.could_not_execute_query",
                                      searchString));
            }
        }
        catch (MalformedURLException e) {
            log.error("Could not connect to server.", e);
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("packages.search.connection_error"));
        }
        catch (ValidatorException ve) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("packages.search.use_free_form"));
        }
        catch (SearchServerIndexException se) {
            log.error("Exception caught: " +  se.getMessage());
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("searchserver.index_out_of_sync_with_db"));
        }

        // keep all params except submitted, in order for the new list
        // tag pagination to work we need to pass along all the formvars it
        // generated.
        Enumeration paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String name = (String) paramNames.nextElement();
            if (!SUBMITTED.equals(name)) {
                forwardParams.put(name, request.getParameter(name));
            }
        }

        forwardParams.put("search_string", searchString);
        forwardParams.put("view_mode", viewMode);
        forwardParams.put("channel_arch", channelArches);

        if (!errors.isEmpty()) {
            addErrors(request, errors);
            return getStrutsDelegate().forwardParams(
                    mapping.findForward("default"),
                    forwardParams);
        }

        return getStrutsDelegate().forwardParams(
                mapping.findForward("success"),
                forwardParams);
    }

    private void setupForm(HttpServletRequest request, DynaActionForm form)
        throws MalformedURLException, XmlRpcFault, SearchServerIndexException {

        RequestContext ctx = new RequestContext(request);
        String searchString = form.getString("search_string");
        String viewmode = form.getString("view_mode");
        String searchCriteria = request.getParameter(WHERE_CRITERIA);
        String[] selectedArches = null;
        Long filterChannelId = null;
        boolean relevantFlag = false;

        // Default to relevant channels if no search criteria was specified
        if (searchCriteria == null || searchCriteria.equals("")) {
            searchCriteria = "relevant";
        }

        // Handle the radio button selection for channel filtering
        if (searchCriteria.equals("relevant")) {
            relevantFlag = true;
        }
        if (searchCriteria.equals("architecture")) {
            /* The search call will function as being scoped to architectures if the arch
               list isn't null. In order to actually get radio-button-like functionality
               we can't rely on the arch list coming in from the form to be null; the
               user may have selected an arch but *not* the radio button for arch. If we
               push off retrieving the arches until we know we want to use them, we can
               get the desired functionality described by the UI.
              */
            selectedArches = form.getStrings("channel_arch");
        }
        else if (searchCriteria.equals("channel")) {
            String sChannelId = form.getString("channel_filter");
            filterChannelId = Long.parseLong(sChannelId);
        }

        if (viewmode.equals("")) { //first time viewing page
            viewmode = PackageSearchHelper.OPT_NAME_AND_SUMMARY;
        }

        List searchOptions = new ArrayList();
        // setup the option list for select box (view_mode).
        addOption(searchOptions, "packages.search.free_form",
                PackageSearchHelper.OPT_FREE_FORM);
        addOption(searchOptions, "packages.search.name",
                PackageSearchHelper.OPT_NAME_ONLY);
        addOption(searchOptions, "packages.search.name_and_desc",
                PackageSearchHelper.OPT_NAME_AND_DESC);
        addOption(searchOptions, "packages.search.both",
                PackageSearchHelper.OPT_NAME_AND_SUMMARY);

        List channelArches = new ArrayList();
        List<ChannelArch> arches = ChannelManager.getChannelArchitectures();
        List<String> archLabels = ChannelManager.getSyncdChannelArches();
        for (ChannelArch arch : arches) {
            boolean exclude = false;
            for (String s : EXCLUDE_ARCH_LABELS) {
                if (arch.getLabel().equals(s)) {
                    exclude = true;
                    break;
                }
            }

            if (!exclude) {
                // if the label does *NOT* exist, this channel arch has no
                // channels in the database. So we want to flag it.
                addOption(channelArches, arch.getName(), arch.getLabel(),
                        !archLabels.contains(arch.getLabel()));
            }
        }

        // Load list of available channels to select as filter
        List allChannels =
            ChannelManager.allChannelsTree(ctx.getLoggedInUser());

        request.setAttribute("search_string", searchString);
        request.setAttribute("view_mode", viewmode);
        request.setAttribute("searchOptions", searchOptions);
        request.setAttribute("channelArches", channelArches);
        request.setAttribute("channel_arch", selectedArches);
        request.setAttribute("allChannels", allChannels);
        request.setAttribute("channel_filter", form.getString("channel_filter"));
        request.setAttribute("relevant", relevantFlag ? "yes" : "no");

        // Default where to search criteria
        request.setAttribute("whereCriteria", searchCriteria);

        if (!StringUtils.isBlank(searchString)) {
            List<PackageOverview> results =
                PackageSearchHelper.performSearch(ctx.getWebSession().getId(),
                                         searchString,
                                         viewmode,
                                         selectedArches, relevantFlag);

            // Perform any post-search logic that wasn't done by the search server
            results = removeDuplicateNames(results);

            if (filterChannelId != null) {
                User user = ctx.getLoggedInUser();
                results = filterByChannel(user, filterChannelId, results);
            }

            log.warn("GET search: " + results);
            request.setAttribute("pageList",
                    results != null ? results : Collections.EMPTY_LIST);
        }
        else {
            request.setAttribute("pageList", Collections.EMPTY_LIST);
        }
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
        for (PackageOverview pkgOver : pkgs) {
            boolean addPkg = true;
            for (PackageOverview temp : result) {
                if (StringUtils.equals(temp.getPackageName(), pkgOver.getPackageName())) {
                    addPkg = false;
                    break;
                }
            }
            if (addPkg) {
                result.add(pkgOver);
            }
        }
        return result;
    }

    /**
     * Since the search server does not carry channel information, we do any channel
     * filtering in the Java stack. This method will return a new list of packages that
     * containing packages that are present in the given channel; others returned from
     * the search will be removed.
     *
     * @param user      user making the request
     * @param channelId channel against which the filter should be run
     * @param pkgs      list of packages returned from the search query that should be
     *                  filtered
     * @return new list object with duplicates removed; does not change the list in place
     */
    private List<PackageOverview> filterByChannel(User user, Long channelId,
                                                  List<PackageOverview> pkgs) {

        Channel channel = ChannelManager.lookupByIdAndUser(channelId, user);
        List<PackageDto> allPackagesList = ChannelManager.listAllPackages(channel);

        // Convert the package list into a map for quicker lookup
        Map<String, String> packageNamesMap =
            new HashMap<String, String>(allPackagesList.size());

        for (PackageDto dto : allPackagesList) {
            String name = dto.getName();
            packageNamesMap.put(name, name);
        }

        // Iterate results and remove if not in the channel
        List<PackageOverview> newResult = new ArrayList<PackageOverview>();
        for (PackageOverview pkg : pkgs) {
            String packageName = pkg.getPackageName();
            if (packageNamesMap.get(packageName) != null) {
                newResult.add(pkg);
            }
        }

        return newResult;
    }

    private void addOption(List options, String key, String value) {
        addOption(options, key, value, false);
    }

    /**
     * Utility function to create options for the dropdown.
     * @param options list containing all options.
     * @param key resource bundle key used as the display value.
     * @param value value to be submitted with form.
     * @param flag Flag the item with an asterisk (*) indicating it is *not*
     * synch'd
     */
    private void addOption(List options, String key, String value, boolean flag) {
        LocalizationService ls = LocalizationService.getInstance();
        Map selection = new HashMap();
        selection.put("display", (flag ? "*" : "") + ls.getMessage(key));
        selection.put("value", value);
        options.add(selection);
    }
}
