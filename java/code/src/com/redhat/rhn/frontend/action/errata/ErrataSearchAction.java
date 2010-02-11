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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.action.common.DateRangePicker;
import com.redhat.rhn.frontend.action.common.DateRangePicker.DatePickerResults;
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
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.TimeZone;

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
        
        // Process the dates, default the start date to yesterday
        // and end date to today.
        Calendar today = Calendar.getInstance();
        today.setTime(new Date());
        Calendar yesterday = Calendar.getInstance();
        yesterday.setTime(new Date());
        yesterday.add(Calendar.DAY_OF_YEAR, -1);

        DateRangePicker picker = new DateRangePicker(form, request,
                yesterday.getTime(),
                today.getTime(),
                DatePicker.YEAR_RANGE_NEGATIVE,
                "erratasearch.jsp.start_date",
                "erratasearch.jsp.end_date");
        DatePickerResults dates = null;
        Boolean dateSearch = getOptionIssueDateSearch(request);

        /*
         * If search/viewmode aren't null, we need to search and set
         * pageList to the resulting DataResult.
         * 
         * NOTE:  There is a special case when called from rhn/Search.do 
         * (header search bar)
         * that we will be coming into this action and running the 
         * performSearch on the first run through this action, i.e. 
         * we'll never have been called with search being blank, 
         * therefore normal setup of the form vars will not have happened.
         */
        if (!StringUtils.isBlank(search) || dateSearch) {
            // If doing a dateSearch use the DatePicker values from the 
            // request params otherwise use the defaults.
            dates = picker.processDatePickers(dateSearch);
            if (log.isDebugEnabled()) {
                log.debug("search is NOT blank");
                log.debug("Issue Start Date = " + dates.getStart().getDate());
                log.debug("End Start Date = " + dates.getEnd().getDate());
            }
            List results = performSearch(request, ctx.getWebSession().getId(),
                    search, viewmode, form);
            
            log.warn("GET search: " + results);
            request.setAttribute("pageList",
                    results != null ? results : Collections.EMPTY_LIST);
        }
        else {
            // Reset info on date pickers
            dates = picker.processDatePickers(false);
            if (log.isDebugEnabled()) {
                log.debug("search is blank");
                log.debug("Issue Start Date = " + dates.getStart().getDate());
                log.debug("End Start Date = " + dates.getEnd().getDate());
            }
            request.setAttribute("pageList", Collections.EMPTY_LIST);
            Map paramMap = request.getParameterMap();
            if (!paramMap.containsKey("optionIssueDateSearch")) {
                form.set("optionIssueDateSearch", Boolean.FALSE);
            }
            if (!paramMap.containsKey("errata_type_bug")) {
                form.set("errata_type_bug", Boolean.TRUE);
            }
            if (!paramMap.containsKey("errata_type_security")) {
                form.set("errata_type_security", Boolean.TRUE);
            }
            if (!paramMap.containsKey("errata_type_enhancement")) {
                form.set("errata_type_enhancement", Boolean.TRUE);
            }
        }
        ActionMessages dateErrors = dates.getErrors();
        addErrors(request, dateErrors);
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
            String searchString, String mode, DynaActionForm formIn)
        throws XmlRpcFault, MalformedURLException {

        log.warn("Performing errata search");
        RequestContext ctx = new RequestContext(request);
        Org org = ctx.getCurrentUser().getOrg();
        // call search server
        XmlRpcClient client = new XmlRpcClient(
                ConfigDefaults.get().getSearchServerUrl(), true);
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
        //
        // Note:  This is how "issue date" search works.
        // It functions in one of 2 ways, depending on the state of "searchString"
        // 1) It's a database lookup for all errata issued between the given range
        // - OR -
        // 2) It's a filter performed AFTER the regular search.
        //
        // The database lookup happens when no searchstring was specified,
        // i.e. searchString is blank.  This signifies to do a full lookup to the
        // database....through the search-server as "db.search".
        //
        // The second responsibility is to filter results from a returned search.
        // This will happen when searchString is not empty AND issue date search
        // has been activated. Search will proceed as normal, then the final step
        // will be to filter the results by issue date.
        //
        Boolean dateSearch = getOptionIssueDateSearch(request);
        log.debug("Datesearch is " + dateSearch);

        Date startDate = getPickerDate(request, "start");
        Date endDate = getPickerDate(request, "end");

        if (dateSearch && StringUtils.isBlank(searchString)) {
            // this is a full issue date search, not just a filter
            args.add("listErrataByIssueDateRange:(" + getDateString(startDate) +
                    ", " + getDateString(endDate) + ")");
        }
        else {
            args.add(preprocessSearchString(searchString, mode));
        }

        if ((dateSearch && StringUtils.isBlank(searchString)) || OPT_CVE.equals(mode)) {
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
            unsorted = ErrataManager.searchByPackageIdsWithOrg(ids,
                    ctx.getCurrentUser().getOrg());

        }
        else {
            unsorted = fleshOutErrataOverview(ids, org);
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
        // Filter based on errata type selected
        List<ErrataOverview> filteredByType = new ArrayList<ErrataOverview>();
        filteredByType = filterByAdvisoryType(unsorted, formIn);

        List<ErrataOverview> filteredByIssueDate = new ArrayList<ErrataOverview>();
        if (dateSearch && !StringUtils.isBlank(searchString)) {
            // search string is not blank, therefore a search was run so filter the results
            log.debug("Performing filter on issue date, we only want records between " +
                startDate + " - " + endDate);
            filteredByIssueDate = filterByIssueDate(filteredByType, startDate, endDate);
            filtered.addAll(filteredByIssueDate);
        }
        else {
            // skip issue date filter
            filtered.addAll(filteredByType);
        }

        if (log.isDebugEnabled()) {
            log.debug(filtered.size() + " records have passed being filtered " +
                "and will be displayed.");
        }

        // TODO: need to figure out a way to properly sort the
        // errata from a package search. What we get back from the
        // search server is pid, pkg-name in relevant order.
        // What we get back from searchByPackageIds, is an unsorted
        // list of ErrataOverviews where each one contains more than one
        // package-name, but no package ids.
        if (OPT_PKG_NAME.equals(mode)) {
            return filtered;
        }
        
        // Using a lookup map created from the results returned by search server.
        // The issue is that the search server returns us a list in a order which is
        // relevant to score the object received from the search.
        // When we "flesh" out the ErrataOverview by calling into the database we
        // lose this order, that's what we are trying to reclaim, this way when then
        // results are returned to the webpage they will be in a meaningfull order.
        List<ErrataOverview> ordered = new LinkedList<ErrataOverview>();

        for (ErrataOverview eo : filtered) {
            if (log.isDebugEnabled()) {
                log.debug("Processing eo: " + eo.getAdvisory() + " id: " + eo.getId());
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
    
    private List<ErrataOverview> filterByIssueDate(List<ErrataOverview> unfiltered,
            Date startDate, Date endDate) {
        if (log.isDebugEnabled()) {
            log.debug("Filtering " + unfiltered.size() + " records based on Issue Date");
            log.debug("Allowed issue date range is " + startDate + " to " + endDate);
        }
        List<ErrataOverview> filteredByIssueDate = new ArrayList<ErrataOverview>();
        for (ErrataOverview eo : unfiltered) {
            if (eo.getIssueDateObj().after(startDate) &&
                    eo.getIssueDateObj().before(endDate)) {
                filteredByIssueDate.add(eo);
            }
        }
       return filteredByIssueDate;
    }

    private List<ErrataOverview> filterByAdvisoryType(List<ErrataOverview> unfiltered,
            DynaActionForm formIn) {
        if (log.isDebugEnabled()) {
            log.debug("Filtering " + unfiltered.size() + " records based on Advisory type");
            log.debug("BugFixes = " + formIn.get("errata_type_bug"));
            log.debug("Security = " + formIn.get("errata_type_security"));
            log.debug("Enhancement = " + formIn.get("errata_type_enhancement"));
        }
        List<ErrataOverview> filteredByType = new ArrayList<ErrataOverview>();
        for (ErrataOverview eo : unfiltered) {
            Boolean type = null;
            if (eo.isBugFix()) {
                type = (Boolean)formIn.get("errata_type_bug");
                if (type != null) {
                    if (type) {
                            filteredByType.add(eo);
                    }
                }
            }
            if (eo.isSecurityAdvisory()) {
                type = (Boolean)formIn.get("errata_type_security");
                if (type != null) {
                    if (type) {
                        filteredByType.add(eo);
                    }
                }
            }
            if (eo.isProductEnhancement()) {
                type = (Boolean)formIn.get("errata_type_enhancement");
                if (type != null) {
                    if (type) {
                        filteredByType.add(eo);
                    }
                }
            }
        }
        return filteredByType;
    }



    private List<ErrataOverview> fleshOutErrataOverview(List<Long> idsIn, Org org) {
        // Chunk the work to avoid issue with Oracle not liking
        // an input parameter list to contain more than 1000 entries.
        // issue most commonly seen with issue date range search
        List<ErrataOverview> unsorted = new ArrayList<ErrataOverview>();
        int chunkCount = 500;
        if (chunkCount > idsIn.size()) {
            chunkCount = idsIn.size();
        }
        int toIndex = chunkCount;
        int recordsRead = 0;
        while (recordsRead < idsIn.size()) {
            List<Long> chunkIDs = idsIn.subList(recordsRead, toIndex);
            if (chunkIDs.size() == 0) {
                log.warn("Processing 0 size chunkIDs....something seems wrong.");
                break;
            }
            List<ErrataOverview> temp = ErrataManager.search(chunkIDs, org);
            unsorted.addAll(temp);
            toIndex += chunkCount;
            recordsRead += chunkIDs.size();
            if (toIndex >= idsIn.size()) {
                toIndex = idsIn.size();
            }
        }
        return unsorted;
    }



    private String getDateString(Date date) {
        Calendar cal = Calendar.getInstance(TimeZone.getDefault());
        cal.setTime(date);
        String dateFmt = "yyyy-MM-dd HH:mm:ss";
        java.text.SimpleDateFormat sdf =
            new java.text.SimpleDateFormat(dateFmt);
        sdf.setTimeZone(TimeZone.getDefault());
        String currentTime = sdf.format(cal.getTime());
        return currentTime;
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
            query = escapeSpecialChars(query);
            return "(description:(" + query + ") topic:(" + query + ") solution:(" +
                query + ") notes:(" + query + ") product:(" + query + ")" +
                " advisoryName:(" + query + ") synopsis:(" + query + "))";
        }
        else if (OPT_ADVISORY.equals(mode)) {
            query = escapeSpecialChars(query);
            return "(advisoryName:(" + query + "))";
        }
        else if (OPT_PKG_NAME.equals(mode)) {
            // when searching the name field, we also want to include the filename
            // field in case the user passed in version number.
            return "(name:(" + query + ") filename:(" + query + "))";
        }
        else if (OPT_CVE.equals(mode)) {
            if (query.trim().toLowerCase().indexOf("cve-") == -1) {
                query = "CVE-" + query;
            }
            return "listErrataByCVE:(" + query + ")";
        }

        // OPT_FREE_FORM send as is.
        return buf.toString();
    }

    private Date getPickerDate(HttpServletRequest request, String paramName) {
        Date d = null;
        DatePicker dPick = (DatePicker)request.getAttribute(paramName);
        if (dPick == null) {
            log.debug("DatePicker for request attribute '" + paramName + "' was null");
            d = new Date();
        }
        else {
            d = dPick.getDate();
        }
        return d;
    }

    private String escapeSpecialChars(String queryIn) {
        // These are the list of possible chars to escape for Lucene:
        //  + - && || ! ( ) { } [ ] ^ " ~ * ? : \
        String query = queryIn.replace(":", "\\:");
        return query;
    }

    private Boolean getOptionIssueDateSearch(HttpServletRequest request) {
        String strDateSearch = (String)request.getParameter("optionIssueDateSearch");
        if ("on".equals(strDateSearch)) {
            return true;
        }
        return false;
    }


}
