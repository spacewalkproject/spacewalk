/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.frontend.dto.PackageOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
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
import java.util.Arrays;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import redstone.xmlrpc.XmlRpcClient;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcFault;
      
/**
 * PackageSearchAction
 * @version $Rev$
 */
public class PackageSearchAction extends RhnAction {
    private static Logger log = Logger.getLogger(PackageSearchAction.class);

    private static final String OPT_FREE_FORM = "search_free_form";
    private static final String OPT_NAME_AND_DESC = "search_name_and_description";
    private static final String OPT_NAME_AND_SUMMARY = "search_name_and_summary";
    private static final String OPT_NAME_ONLY = "search_name";
    /** List of channel arches we don't really support any more. */
    private static final String[] EXCLUDE_ARCH_LABELS = {"channel-sparc",
                                                         "channel-alpha",
                                                         "channel-iSeries",
                                                         "channel-pSeries"};

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
        catch (PackageSearchActionException pe) {
            log.error("Exception caught: " +  pe.getMessage());
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage(pe.getMessageKey()));
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
        throws MalformedURLException, XmlRpcFault, PackageSearchActionException {

        RequestContext ctx = new RequestContext(request);
        String searchString = form.getString("search_string");
        String viewmode = form.getString("view_mode");
        String relevant = StringUtils.defaultString(
                            request.getParameter("relevant"));
        String[] selectedArches = form.getStrings("channel_arch");
        
        if (selectedArches.length < 1) {
            relevant = "yes";
        }
        
        if (viewmode.equals("")) { //first time viewing page
            relevant = "yes";
            viewmode = OPT_NAME_AND_SUMMARY;
        }
        
        List searchOptions = new ArrayList();
        // setup the option list for select box (view_mode).
        addOption(searchOptions, "packages.search.free_form", OPT_FREE_FORM);
        addOption(searchOptions, "packages.search.name", OPT_NAME_ONLY);
        addOption(searchOptions, "packages.search.name_and_desc", OPT_NAME_AND_DESC);
        addOption(searchOptions, "packages.search.both", OPT_NAME_AND_SUMMARY);
        
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

        request.setAttribute("search_string", searchString);
        request.setAttribute("view_mode", viewmode);
        request.setAttribute("relevant", relevant);
        request.setAttribute("searchOptions", searchOptions);
        request.setAttribute("channelArches", channelArches);
        request.setAttribute("channel_arch", selectedArches);

        if (!StringUtils.isBlank(searchString)) {
            List results = performSearch(ctx.getWebSession().getId(),
                                         searchString,
                                         viewmode,
                                         selectedArches);
            log.warn("GET search: " + results);
            request.setAttribute("pageList",
                    results != null ? results : Collections.EMPTY_LIST);
        }
        else {
            request.setAttribute("pageList", Collections.EMPTY_LIST);
        }
    }
    
    private List performSearch(Long sessionId, String searchString,
                               String mode, String[] selectedArches)
        throws XmlRpcFault, MalformedURLException, PackageSearchActionException {

        log.warn("Performing pkg search");

        List<String> pkgArchLabels = 
            ChannelManager.listCompatiblePackageArches(selectedArches);

        // call search server
        XmlRpcClient client = new XmlRpcClient(Config.get().getSearchServerUrl(), true);
        List args = new ArrayList();
        args.add(sessionId);
        args.add("package");
        args.add(preprocessSearchString(searchString, mode, pkgArchLabels));
        if (OPT_FREE_FORM.equals(mode)) {
            // adding a boolean of true to signify we want the results to be
            // constrained to closer matches, this will force the Lucene Queries
            // to use a "MUST" instead of the default "SHOULD".  It will not
            // allow fuzzy matches as in spelling errors, but it will allow
            // free form searches to do more advanced options
            args.add(true);
        }
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
        List<PackageOverview> unsorted = ChannelManager.packageSearch(pids,
                new ArrayList<String>(Arrays.asList(selectedArches)));
        List<PackageOverview> ordered = new LinkedList<PackageOverview>();
        
        // we need to use the package names to determine the mapping order
        // because the id in PackageOverview is that of a PackageName while
        // the id from the search server is the Package id.
        for (PackageOverview po : unsorted) {
            if (log.isDebugEnabled()) {
                log.debug("Processing po: " + po.getPackageName() + " id: " + po.getId());
            }
            Object objIdx = lookupmap.get(po.getPackageName());
            if (objIdx == null) {
                String msgKey = "packages.search.index_out_of_sync_with_db";
                LocalizationService li = LocalizationService.getInstance();
                String localizedMsg = li.getMessage(msgKey);
                throw new PackageSearchActionException(localizedMsg, msgKey);
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
    
    private String preprocessSearchString(String searchstring,
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
