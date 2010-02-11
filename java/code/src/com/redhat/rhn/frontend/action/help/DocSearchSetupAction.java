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
package com.redhat.rhn.frontend.action.help;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.frontend.context.Context;
import com.redhat.rhn.frontend.dto.HelpDocumentOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;

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
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import redstone.xmlrpc.XmlRpcClient;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcFault;

/**
 * DocSearchSetupAction
 * @version $Rev$
 */
public class DocSearchSetupAction extends RhnAction {
    private static Logger log = Logger.getLogger(DocSearchSetupAction.class);

    private static final String OPT_FREE_FORM = "search_free_form";
    private static final String OPT_CONTENT_ONLY = "search_content";
    private static final String OPT_TITLE_ONLY = "search_title";
    private static final String OPT_CONTENT_TITLE = "search_content_title";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn, 
            HttpServletRequest request, HttpServletResponse response) {

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
        String searchString = form.getString("search_string");
        String viewmode = form.getString("view_mode");
        
        List searchOptions = new ArrayList();
        
        addOption(searchOptions, "docsearch.content_title", OPT_CONTENT_TITLE);
        addOption(searchOptions, "docsearch.free_form", OPT_FREE_FORM);
        addOption(searchOptions, "docsearch.content", OPT_CONTENT_ONLY);
        addOption(searchOptions, "docsearch.title", OPT_TITLE_ONLY);

        request.setAttribute("search_string", searchString);
        request.setAttribute("view_mode", viewmode);
        request.setAttribute("searchOptions", searchOptions);


        if (!StringUtils.isBlank(searchString)) {
            List results = performSearch(ctx.getWebSession().getId(),
                                         searchString,
                                         viewmode);
            log.debug("GET search: " + results);
            request.setAttribute("pageList",
                    results != null ? results : Collections.EMPTY_LIST);
        }
        else {
            request.setAttribute("pageList", Collections.EMPTY_LIST);
        }
    }
    
    private List performSearch(Long sessionId, String searchString,
                               String mode)
        throws XmlRpcFault, MalformedURLException {

        log.debug("Performing doc search");

        // call search server
        XmlRpcClient client = new XmlRpcClient(
                ConfigDefaults.get().getSearchServerUrl(), true);
        List args = new ArrayList();
        args.add(sessionId);
        args.add("docs");
        args.add(preprocessSearchString(searchString, mode));
        // get lang we are searching in
        Locale l = Context.getCurrentContext().getLocale();
        args.add(l.toString());
        Boolean searchFreeForm = false;
        if (OPT_FREE_FORM.equals(mode)) {
            // adding a boolean of true to signify we want the results to be
            // constrained to closer matches, this will force the Lucene Queries
            // to use a "MUST" instead of the default "SHOULD".  It will not
            // allow fuzzy matches as in spelling errors, but it will allow
            // free form searches to do more advanced options
            //args.add(true);
            searchFreeForm = true;
        }
        args.add(searchFreeForm);
        List results = (List)client.invoke("index.search", args);

        if (log.isDebugEnabled()) {
            log.debug("results = [" + results + "]");
        }

        if (results.isEmpty()) {
            return Collections.EMPTY_LIST;
        }

        List<HelpDocumentOverview> docs = new ArrayList<HelpDocumentOverview>();
        for (int x = 0; x < results.size(); x++) {
            HelpDocumentOverview doc = new HelpDocumentOverview();
            Map item = (Map) results.get(x);
            log.debug("SearchServer sent us item [" + item.get("rank") + "], score = " +
                    item.get("score") + ", summary = " + item.get("summary") +
                    ", title = " + item.get("title") + ", url = " + item.get("url"));
            doc.setUrl((String)item.get("url"));
            doc.setTitle((String)item.get("title"));
            doc.setSummary((String)item.get("summary"));
            docs.add(doc);
        }
        return docs;
    }
    
    private String preprocessSearchString(String searchstring,
                                          String mode) {

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
        

        String query = buf.toString().trim();
        // when searching the name field, we also want to include the filename
        // field in case the user passed in version number.
       if (OPT_CONTENT_ONLY.equals(mode)) {
            return "(content:(" + query + "))";
        }
       else if (OPT_TITLE_ONLY.equals(mode)) {
           return "(title:(" + query + "))";
       }
       else if (OPT_CONTENT_TITLE.equals(mode)) {
           return "(content:(" + query + ") title:(" + query + "))";
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
