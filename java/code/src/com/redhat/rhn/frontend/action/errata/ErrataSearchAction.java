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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.errata.ErrataManager;

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

import redstone.xmlrpc.XmlRpcClient;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcFault;

/**
 * SearchAction
 * @version $Rev$
 */
public class ErrataSearchAction extends RhnAction {
    
    private static Logger log = Logger.getLogger(ErrataSearchAction.class);
    private static final String OPT_ADVISORY = "errata_search_by_advisory";
    private static final String OPT_PKG_NAME = "errata_search_by_package_name";
    private static final String OPT_CVE = "errata_search_by_cve";
    private static final String OPT_ISSUE_DATE = "errata_search_by_issue_date";
    private static final String OPT_ALL_FIELDS = "errata_search_by_all_fields";
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        ActionErrors errors = new ActionErrors();
        DynaActionForm form = (DynaActionForm)formIn;
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        Map forwardParams = makeParamMap(request);
        String searchString = request.getParameter("search_string");
        String viewMode = form.getString("view_mode");
        
        if (log.isDebugEnabled()) {
            log.debug("form.errata_type_bug = " + form.get("errata_type_bug"));
            log.debug("form.errata_type_security = " + form.get("errata_type_security"));
            log.debug("form.errata_type_enhancement = " +
                    form.get("errata_type_enhancement"));
        }
        log.debug("isSubmitted = " + isSubmitted(form));
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
            ActionMessage errorMsg = null;
            if (e.getErrorCode() == 100) {
                log.error("Invalid search query", e);
                errorMsg = new ActionMessage("packages.search.could_not_parse_query",
                        searchString);
            }
            else {
                errorMsg = new ActionMessage("errata.search.could_not_execute_query",
                        searchString);
                log.warn("XmlRpcFault error code: " + e.getErrorCode() + " caught: " +
                        e.getMessage());
            }
            e.printStackTrace();
            errors.add(ActionMessages.GLOBAL_MESSAGE, errorMsg);
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
        throws MalformedURLException, XmlRpcFault {
        RequestContext ctx = new RequestContext(request);
        
        String search = request.getParameter("search_string");
        String viewmode = request.getParameter("view_mode");
        
        List searchOptions = new ArrayList();
        // setup the option list for select box (view_mode).
        addOption(searchOptions, "errata_search_by_all_fields", OPT_ALL_FIELDS);
        addOption(searchOptions, "errata_search_by_advisory", OPT_ADVISORY);
        addOption(searchOptions, "errata_search_by_package_name", OPT_PKG_NAME);
        addOption(searchOptions, "errata_search_by_cve", OPT_CVE);
        
        request.setAttribute("search_string", search);
        request.setAttribute("view_mode", viewmode);
        request.setAttribute("searchOptions", searchOptions);
        

        //create and prepopulate the date picker.
        DatePicker startPicker = getStrutsDelegate().prepopulateDatePicker(ctx.getRequest(),
                form, "startDate", DatePicker.YEAR_RANGE_POSITIVE);
        DatePicker endPicker = getStrutsDelegate().prepopulateDatePicker(ctx.getRequest(),
                form, "endDate", DatePicker.YEAR_RANGE_POSITIVE);
        ctx.getRequest().setAttribute("startDate", startPicker);
        ctx.getRequest().setAttribute("endDate", endPicker);

        /*
         * If search/viewmode aren't null, we need to search and set
         * pageList to the resulting DataResult.
         */
        if (!StringUtils.isBlank(search)) {
            List results = performSearch(request, ctx.getWebSession().getId(),
                    search, viewmode, form);
            
            log.warn("GET search: " + results);
            request.setAttribute("pageList",
                    results != null ? results : Collections.EMPTY_LIST);
        }
        else {
            request.setAttribute("pageList", Collections.EMPTY_LIST);

            form.set("errata_type_bug", Boolean.TRUE);
            form.set("errata_type_security", Boolean.TRUE);
            form.set("errata_type_enhancement", Boolean.TRUE);
            form.set("optionIssueDateSearch", "ALL_DATES");
            form.set("optionSearchWithEndDate", Boolean.FALSE);
        }
    }
    
    /**
     * Utility function to create options for the dropdown.
     * @param options list containing all options.
     * @param key resource bundle key used as the display value.
     * @param value value to be submitted with form.
     */
    private void addOption(List options, String key, String value) {
        LocalizationService ls = LocalizationService.getInstance();
        Map selection = new HashMap();
        selection.put("display", ls.getMessage(key));
        selection.put("value", value);
        options.add(selection);
    }
    
    private List performSearch(HttpServletRequest request, Long sessionId,
            String searchString, String mode, DynaActionForm form)
        throws XmlRpcFault, MalformedURLException {

        log.warn("Performing errata search");

        // call search server
        XmlRpcClient client = new XmlRpcClient(Config.get().getSearchServerUrl(), true);
        String path = null;
        List args = new ArrayList();
        args.add(sessionId);
        // do a package search instead of an errata one. This uses
        // a different lucene index to find pkgs then reconciles
        // them with the errata later.
        if (OPT_PKG_NAME.equals(mode)) {
            args.add("package");
        }
        else {
            args.add("errata");
        }

        List results = new ArrayList();
        args.add(preprocessSearchString(searchString, mode));

        if (OPT_ISSUE_DATE.equals(mode) | OPT_CVE.equals(mode)) {
            // Tells search server to search the database
            path = "db.search";
        }
        else {
            // Tells search server to use the lucene index
            path = "index.search";
        }

        if (log.isDebugEnabled()) {
            log.debug("Calling to search server (XMLRPC):  \"index.search\", args=" + args);
        }
        results = (List)client.invoke(path, args);

        if (log.isDebugEnabled()) {
            log.debug("results = [" + results + "]");
        }

        if (results.isEmpty()) {
            return Collections.EMPTY_LIST;
        }

        // need to make the search server results usable by database
        // so we can get the actual results we are to display to the user.
        // also save the items into a Map for lookup later.
        
        List<Long> ids = new ArrayList<Long>();
        Map<Long, Integer> lookupmap = new HashMap<Long, Integer>();
        // do it in reverse because the search server can return more than one
        // record for a given package name, but that means if we don't go
        // in reverse we risk getting the wrong rank in the lookupmap.
        // for example, [{id:125,name:gtk},{id:127,name:gtk}{id:200,name:kernel}]
        // if we go forward we end up with gtk:1 and kernel:2 but we wanted
        // kernel:2, gtk:0.
        for (int x = results.size() - 1; x >= 0; x--) {
            Map item = (Map) results.get(x);
            lookupmap.put(new Long((String)item.get("id")), x);
            Long id = new Long((String)item.get("id"));
            ids.add(id);
        }
        
        // The database does not maintain the order of the where clause.
        // In order to maintain the ranking from the search server, we
        // need to reorder the database results to match. This will lead
        // to a better user experience.
        List<ErrataOverview> unsorted = new ArrayList<ErrataOverview>();
        if (OPT_PKG_NAME.equals(mode)) {
            unsorted = ErrataManager.searchByPackageIds(ids);
            // TODO: need to figure out a way to properly sort the
            // errata from a package search. What we get back from the
            // search server is pid, pkg-name in relevant order.
            // What we get back from searchByPackageIds, is an unsorted
            // list of ErrataOverviews where each one contains more than one
            // package-name, but no package ids. 
            //return unsorted;
        }
        else {
            // Chunk the work to avoid issue with Oracle not liking
            // an input parameter list to contain more than 1000 entries.
            // issue most commonly seen with issue date range search
            int chunkCount = 500;
            if (chunkCount > ids.size()) {
                chunkCount = ids.size();
            }
            int toIndex = chunkCount;
            int recordsRead = 0;
            log.debug("BEFORE CHUNKING ids.size() = " + ids.size() +
                    ", chunkCount = " + chunkCount);
            while (recordsRead < ids.size()) {
                log.debug("Preparing chunk for : fromIndex=" + recordsRead +
                        ", toIndex=" + toIndex);
                List<Long> chunkIDs = ids.subList(recordsRead, toIndex);
                if (chunkIDs.size() == 0) {
                    log.warn("Processing 0 size chunkIDs....something seems wrong.");
                    break;
                }
                List<ErrataOverview> temp = ErrataManager.search(chunkIDs);
                unsorted.addAll(temp);
                toIndex += chunkCount;
                recordsRead += chunkIDs.size();
                if (toIndex >= ids.size()) {
                    toIndex = ids.size();
                }
            }
            log.debug("AFTER CHUNKING ids.size() = " + ids.size() +
                    ", recordsRead = " + recordsRead +
                    " unsorted.size() = " + unsorted.size());
        }

        if (OPT_CVE.equals(mode)) {
            // Flesh out all CVEs for each errata returned..generally this is a
            // small number of Errata to operate on.
            for (ErrataOverview eo : unsorted) {
                DataResult dr = ErrataManager.errataCVEs(eo.getId());
                eo.setCves(dr);
            }
        }

        List<ErrataOverview> filtered = new ArrayList<ErrataOverview>();
        // Sort based on errata type selected
        if (log.isDebugEnabled()) {
            log.debug("Filtering based on Advisory type");
            log.debug("BugFixes = " + form.get("errata_type_bug"));
            log.debug("Security = " + form.get("errata_type_security"));
            log.debug("Enhancement = " + form.get("errata_type_enhancement"));
        }
        for (ErrataOverview eo : unsorted) {
            Boolean type = null;
            if (eo.isBugFix()) {
                type = (Boolean)form.get("errata_type_bug");
                if (type != null) {
                    if (type) {
                        filtered.add(eo);
                    }
                }
            }
            if (eo.isSecurityAdvisory()) {
                type = (Boolean)form.get("errata_type_security");
                if (type != null) {
                    if (type) {
                        filtered.add(eo);
                    }
                }
            }
            if (eo.isProductEnhancement()) {
                type = (Boolean)form.get("errata_type_enhancement");
                if (type != null) {
                    if (type) {
                        filtered.add(eo);
                    }
                }
            }
        }

        return filtered;

        /**
         * TODO:  Review below code to see if it's needed.

        List<ErrataOverview> ordered = new LinkedList<ErrataOverview>();
        

        // we need to use the package names to determine the mapping order
        // because the id in PackageOverview is that of a PackageName while
        // the id from the search server is the Package id.
        for (ErrataOverview eo : unsorted) {
            if (log.isDebugEnabled()) {
                log.debug("Processing po: " + eo.getAdvisory() + " id: " + eo.getId());
            }
            int idx = lookupmap.get(eo.getId());
            if (ordered.isEmpty()) {
                ordered.add(eo);
                continue;
            }

            boolean added = false;
            for (ListIterator itr = ordered.listIterator(); itr.hasNext();) {
                ErrataOverview curpo = (ErrataOverview) itr.next();
                int curidx = lookupmap.get(curpo.getId());
                if (idx <= curidx) {
                    itr.previous();
                    itr.add(eo);
                    added = true;
                    break;
                }
            }
            
            if (!added) {
                ordered.add(eo);
            }
        }
        return ordered;
        */
    }
    
    private String preprocessSearchString(String searchstring, String mode) {

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
        String query = buf.toString().trim();
        if (OPT_ALL_FIELDS.equals(mode)) {
            return "(description:(" + query + ") topic:(" + query + ") solution:(" +
                query + ") notes:(" + query + ") product:(" + query + "))";
        }
        else if (OPT_ADVISORY.equals(mode)) {
            return "advisory:(" + query + ")";
        }
        else if (OPT_PKG_NAME.equals(mode)) {
            // when searching the name field, we also want to include the filename
            // field in case the user passed in version number.
            return "(name:(" + query + ") filename:(" + query + "))";
        }
        //else if (OPT_ISSUE_DATE.equals(mode)) {
        //    return "listErrataByIssueDateRange:(" + query + ")";
        //}
        else if (OPT_CVE.equals(mode)) {
            if (query.trim().toLowerCase().indexOf("cve-") == -1) {
                log.debug("Original query = " + query + " will add 'CVE-' to front");
                query = "CVE-" + query;
                log.debug("New query is " + query);
            }
            return "listErrataByCVE:(" + query + ")";
        }
        // OPT_FREE_FORM send as is.
        return buf.toString();
    }
}
