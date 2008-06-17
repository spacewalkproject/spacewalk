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
import com.redhat.rhn.common.localization.LocalizationService;
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
 * SearchAction
 * @version $Rev$
 */
public class ErrataSearchAction extends RhnAction {
    
    private static Logger log = Logger.getLogger(ErrataSearchAction.class);
    private static final String OPT_SIMPLE = "simple_errata_search";
    private static final String OPT_SYNOPSIS = "errata_search_by_synopsis";
    private static final String OPT_ADVISORY = "errata_search_by_advisory";
    private static final String OPT_PKG_NAME = "errata_search_by_package_name";
    
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
            if (e.getErrorCode() == 100) {
                log.error("Invalid search query", e);
            }
            
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("packages.search.could_not_parse_query",
                                      searchString));
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
        addOption(searchOptions, "errata_search_by_synopsis", OPT_SYNOPSIS);
        addOption(searchOptions, "errata_search_by_advisory", OPT_ADVISORY);
        addOption(searchOptions, "errata_search_by_package_name", OPT_PKG_NAME);
        
        request.setAttribute("search_string", search);
        request.setAttribute("view_mode", viewmode);
        request.setAttribute("searchOptions", searchOptions);
        
        /*
         * If search/viewmode aren't null, we need to search and set
         * pageList to the resulting DataResult.
         */
//        if (search != null) {
//            PageControl pc = new PageControl();
//            clampListBounds(pc, request, user);
//
//            DataResult dr = ErrataManager.search(request.getParameter("search_string"), 
//                                                 request.getParameter("view_mode"),
//                                                 user, pc);
//            
//            request.setAttribute("pageList", dr);
//        }

        if (!StringUtils.isBlank(search)) {
            List results = performSearch(ctx.getWebSession().getId(),
                    search, viewmode);
            
            log.warn("GET search: " + results);
            request.setAttribute("pageList",
                    results != null ? results : Collections.EMPTY_LIST);
        }
        else {
            request.setAttribute("pageList", Collections.EMPTY_LIST);
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
    
    private List performSearch(Long sessionId, String searchString,
                               String mode)
        throws XmlRpcFault, MalformedURLException {

        log.warn("Performing errata search");

        // call search server
        XmlRpcClient client = new XmlRpcClient(Config.get().getSearchServerUrl(), true);
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
        args.add(preprocessSearchString(searchString, mode));
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
        List<ErrataOverview> unsorted;
        if (OPT_PKG_NAME.equals(mode)) {
            unsorted = ErrataManager.searchByPackageIds(ids);
            // TODO: need to figure out a way to properly sort the
            // errata from a package search. What we get back from the
            // search server is pid, pkg-name in relevant order.
            // What we get back from searchByPackageIds, is an unsoerted
            // list of ErrataOverviews where each one contains more than one
            // package-name, but no package ids. 
            return unsorted;
        }
        else {
            unsorted = ErrataManager.search(ids);
        }

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
        // when searching the name field, we also want to include the filename
        // field in case the user passed in version number.
        if (OPT_SYNOPSIS.equals(mode)) {
            return "synopsis:(" + query + ")";
        }
        else if (OPT_ADVISORY.equals(mode)) {
            return "advisory:(" + query + ")";
        }
        else if (OPT_PKG_NAME.equals(mode)) {
            return "(name:(" + query + ") filename:(" + query + "))";
        }
        else if (OPT_SIMPLE.equals(mode)) {
            return "(synopsis:(" + query + ") advisory:(" + query + "))";
        }
        
        // OPT_FREE_FORM send as is.
        return buf.toString();
    }
}
