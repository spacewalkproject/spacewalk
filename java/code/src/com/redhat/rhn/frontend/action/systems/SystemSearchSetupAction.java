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
package com.redhat.rhn.frontend.action.systems;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.dto.SystemSearchResult;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.io.IOException;
import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcFault;

/**
 * Action handling the advanced system search page.
 */
public class SystemSearchSetupAction extends RhnAction implements Listable {
    
    public static final String LIST_NAME = "pageList";
    public static final String DATA_SET = "searchResults";
    
    public static final String[] OPT_GROUPS_TITLES = { "systemsearch.jsp.details",
                                                     "systemsearch.jsp.activity", 
                                                     "systemsearch.jsp.hardware", 
                                                     "systemsearch.jsp.devices",
                                                     "systemsearch.jsp.dmiinfo",
                                                     "systemsearch.jsp.networkinfo",
                                                     "systemsearch.jsp.packages",
                                                     "systemsearch.jsp.location"};
    
    public static final String[][] OPT_GROUPS = 
                                    {
                                     /* details */
                                     {  SystemSearchHelper.NAME_AND_DESCRIPTION,
                                        SystemSearchHelper.ID,
                                        SystemSearchHelper.CUSTOM_INFO,
                                        SystemSearchHelper.SNAPSHOT_TAG,
                                        SystemSearchHelper.RUNNING_KERNEL
                                     },
                                     /* activity group */
                                     {  SystemSearchHelper.CHECKIN,
                                        SystemSearchHelper.REGISTERED
                                     },
                                     /* hardware group */
                                     {
                                        SystemSearchHelper.CPU_MODEL,
                                        SystemSearchHelper.CPU_MHZ_LT,
                                        SystemSearchHelper.CPU_MHZ_GT,
                                        SystemSearchHelper.NUM_CPUS_LT,
                                        SystemSearchHelper.NUM_CPUS_GT,
                                        SystemSearchHelper.RAM_LT,
                                        SystemSearchHelper.RAM_GT
                                     },
                                     /* device group */
                                     {  SystemSearchHelper.HW_DESCRIPTION,
                                        SystemSearchHelper.HW_DRIVER,
                                        SystemSearchHelper.HW_DEVICE_ID,
                                        SystemSearchHelper.HW_VENDOR_ID
                                     },
                                     /* dmiinfo */
                                     {
                                        SystemSearchHelper.DMI_SYSTEM,
                                        SystemSearchHelper.DMI_BIOS,
                                        SystemSearchHelper.DMI_ASSET
                                     },
                                     /* network info */
                                     {
                                         SystemSearchHelper.HOSTNAME,
                                         SystemSearchHelper.IP
                                     },
                                     /* packages */
                                     {
                                        SystemSearchHelper.INSTALLED_PACKAGES,
                                        SystemSearchHelper.NEEDED_PACKAGES
                                     },
                                     /* location */
                                     {
                                        SystemSearchHelper.LOC_ADDRESS,
                                        SystemSearchHelper.LOC_BUILDING,
                                        SystemSearchHelper.LOC_ROOM,
                                        SystemSearchHelper.LOC_RACK
                                     }};
    
    public static final String SEARCH_STRING = "search_string";
    public static final String VIEW_MODE = "view_mode";
    public static final String WHERE_TO_SEARCH = "whereToSearch";
    public static final String INVERT_RESULTS = "invert";

    private static final String FORM = "FORM";
    private static final String MAPPING = "MAPPING";
    
    private final Logger log = Logger.getLogger(SystemSearchSetupAction.class);

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) 
                                 throws BadParameterException {
        
        
        DynaActionForm daForm = (DynaActionForm) formIn;
        request.setAttribute(FORM, daForm);
        request.setAttribute(MAPPING, mapping);
        
        /*
         * Either the form was submitted (and it's a list action) or 
         *  we have GET arguments and so we can actually render the list
         */
        if (ListTagHelper.getListAction(getListName(), request) != null || 
                (!isSubmitted(daForm) &&
                request.getParameter(VIEW_MODE) != null)) {

            String whereToSearch = daForm.getString(WHERE_TO_SEARCH);
            Boolean invertResults = (Boolean) daForm.get(INVERT_RESULTS);

            if (invertResults == null) {
                invertResults = Boolean.FALSE;
            }
            
            request.setAttribute(VIEW_MODE, request.getParameter(VIEW_MODE));
            request.setAttribute(SEARCH_STRING, request.getParameter(SEARCH_STRING));
            request.setAttribute(WHERE_TO_SEARCH, whereToSearch);

            if (invertResults) {
                request.setAttribute(INVERT_RESULTS, "on");
            }
            else {
                request.setAttribute(INVERT_RESULTS, "off");
            }            
            
            setupForm(request, daForm, request.getParameter(VIEW_MODE));
            
            ListRhnSetHelper helper = new ListRhnSetHelper(this, 
                                            request, RhnSetDecl.SYSTEMS);
            helper.setWillClearSet(false);
            helper.setDataSetName(getDataSetName());
            helper.setListName(getListName());
            helper.execute();

            List results = (List)request.getAttribute(getDataSetName());
            log.info("SystemSearch results.size() = " +
                (results != null ? results.size() : "null results"));
            if ((results != null) && (results.size() == 1)) {
                SystemSearchResult s =  (SystemSearchResult) results.get(0);
                try {
                    response.sendRedirect(
                            "/rhn/systems/details/Overview.do?sid=" +
                            s.getId().toString());
                    return null;
                }
                catch (IOException ioe) {
                    throw new RuntimeException(
                            "Exception while trying to redirect: " + ioe);
                }
            }
            return getStrutsDelegate().forwardParams(
                    mapping.findForward("default"),
                    request.getParameterMap());
        }
        /**
         * Else the form was submitted, so we need to parse the form and turn it into 
         *   GET parameters
         */
        else if (isSubmitted(daForm)) {
            String searchString = daForm.getString(SEARCH_STRING).trim();
            String viewMode = daForm.getString(VIEW_MODE);
            String whereToSearch = daForm.getString(WHERE_TO_SEARCH);
            Boolean invertResults = (Boolean) daForm.get(INVERT_RESULTS);

            if (invertResults == null) {
                invertResults = Boolean.FALSE;
            }
            
            setupForm(request, daForm, viewMode);
            if (whereToSearch == null || viewMode == null) {
                throw new BadParameterException("An expected form var was null");
            }
            
            request.setAttribute(SEARCH_STRING, searchString);
            request.setAttribute(VIEW_MODE, viewMode);
            request.setAttribute(WHERE_TO_SEARCH, whereToSearch);
            
            if (invertResults) {
                request.setAttribute(INVERT_RESULTS, "on");
            }
            else {
                request.setAttribute(INVERT_RESULTS, "off");
            }
            
            ActionErrors errs = new ActionErrors();
            if (viewMode.equals("systemsearch_id") ||
                viewMode.equals(SystemSearchHelper.CPU_MHZ_LT) ||
                viewMode.equals(SystemSearchHelper.CPU_MHZ_GT) ||
                viewMode.equals(SystemSearchHelper.RAM_LT) ||
                viewMode.equals(SystemSearchHelper.RAM_GT) ||
                viewMode.equals(SystemSearchHelper.NUM_CPUS_LT) ||
                viewMode.equals(SystemSearchHelper.NUM_CPUS_GT) ||
                viewMode.equals(SystemSearchHelper.CHECKIN) ||
                viewMode.equals(SystemSearchHelper.REGISTERED)) {
                     String regEx = "(\\d)*";
                     Pattern pattern = Pattern.compile(regEx);
                     Matcher matcher = pattern.matcher(searchString);
                     if (!matcher.matches()) {
                         errs.add(ActionMessages.GLOBAL_MESSAGE,
                                     new ActionMessage("systemsearch.errors.numeric"));
                     }
                 }

                  errs.add(RhnValidationHelper.validateDynaActionForm(this, daForm));

                  if (!errs.isEmpty()) {
                      addErrors(request, errs);
                      request.setAttribute(SEARCH_STRING, null);
                      daForm.set(SEARCH_STRING, null);
                      return mapping.findForward("error");
                  }
                  
                  Map forwardParams = makeParamMap(request);
                  Enumeration paramNames = request.getParameterNames();
                  while (paramNames.hasMoreElements()) {
                      String name = (String) paramNames.nextElement();
                      if (!SUBMITTED.equals(name)) {
                          forwardParams.put(name, request.getParameter(name));
                      }

                  }
                  
                  
                  return getStrutsDelegate().forwardParams(
                          mapping.findForward("success"), 
                          forwardParams);                  
                  
        }
        /**
         * Finally, if we're not actually going to display the list
         *   and the form hasn't been submitted, then we're just displaying the 
         *   initial search page before  a search has been initiated.
         */
        else {
            setupForm(request, daForm, null);
            request.setAttribute(VIEW_MODE, "systemsearch_name_and_description");
            daForm.set(WHERE_TO_SEARCH, "all");
            return getStrutsDelegate().forwardParams(
                    mapping.findForward("default"),
                    request.getParameterMap());
        }
        
    }
    
    protected void setupForm(HttpServletRequest request, 
                             DynaActionForm form, 
                             String viewMode) {
        HashMap optGroupsMap = new HashMap();
        boolean matchingViewModeFound = false;
        
        /* Here we set up a hashmap using the string resources key for the various options 
         * group as a key into the hash, and the string resources/database mode keys as 
         * the values of the options that are contained within each opt group. The jsp 
         * uses this hashmap to setup a dropdown box
         */
        for (int j = 0; j < OPT_GROUPS_TITLES.length; ++j) {
            List options = new ArrayList();
            
            for (int k = 0; k < OPT_GROUPS[j].length; ++k) {
                options.add(createDisplayMap(LocalizationService.getInstance()
                            .getMessage(OPT_GROUPS[j][k]),
                            OPT_GROUPS[j][k]));
                
                if (OPT_GROUPS[j][k].equals(viewMode)) {
                    matchingViewModeFound = true;
                }
            }
            
            optGroupsMap.put(OPT_GROUPS_TITLES[j], options);
        }
        
        if (viewMode != null && !matchingViewModeFound) {
            throw new BadParameterException("Bad viewMode passed in from form");
        }
        
        request.setAttribute("optGroupsMap", optGroupsMap);
        request.setAttribute("optGroupsKeys", optGroupsMap.keySet());
    }

    protected DataResult performSearch(RequestContext context) {

        HttpServletRequest request = context.getRequest();
        String searchString = context.getParam(SEARCH_STRING, false);
        String viewMode = context.getParam(VIEW_MODE, false);
        String whereToSearch = context.getParam(WHERE_TO_SEARCH, false);
        Boolean invertResults = StringUtils.defaultString(
                context.getParam(INVERT_RESULTS, false)).equals("on");
        
        if (invertResults == null) {
            invertResults = Boolean.FALSE;
        }
        ActionErrors errs = new ActionErrors();
        DataResult dr = null;
        try {
            dr = SystemSearchHelper.systemSearch(context,
                    searchString,
                    viewMode,
                    invertResults,
                    whereToSearch);
        }
        catch (MalformedURLException e) {
            log.info("Caught Exception :" + e);
            e.printStackTrace();
            errs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("packages.search.connection_error"));
        }
        catch (XmlRpcFault e) {
            log.info("Caught Exception :" + e);
            log.info("ErrorCode = " + e.getErrorCode());
            e.printStackTrace();
            if (e.getErrorCode() == 100) {
                log.error("Invalid search query", e);
                errs.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("packages.search.could_not_parse_query",
                                          searchString));
            }
            else if (e.getErrorCode() == 200) {
                log.error("Index files appear to be missing: ", e);
                errs.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("packages.search.index_files_missing",
                                          searchString));
            }
            else {
                errs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("packages.search.could_not_execute_query",
                                      searchString));
            }
        }
        catch (XmlRpcException e) {
            log.info("Caught Exception :" + e);
            e.printStackTrace();
            errs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("packages.search.connection_error"));
        }
        if (dr == null) {
            ActionMessages messages = new ActionMessages();
            messages.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("systemsearch_no_matches_found"));
            getStrutsDelegate().saveMessages(request, messages);
        }
        if (!errs.isEmpty()) {
            addErrors(request, errs);
        }
        return dr;
    }

    /**
     * Creates a Map with the keys display and value
     * @param display the value for display
     * @param value the value for value
     * @return Returns the map.
     */
    private Map createDisplayMap(String display, String value) {
        Map<String, String> selection = new HashMap<String, String>();
        selection.put("display", display);
        selection.put("value", value);
        return selection;
    }

    /** {@inheritDoc} */
    public String getListName()  {
        return LIST_NAME;
    }

    /** {@inheritDoc} */
    public String getDataSetName() {
        return DATA_SET;
    }

    /** {@inheritDoc} */
    public  String getDecl(RequestContext context) {
        return RhnSetDecl.SYSTEMS.getLabel();
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        String searchString = context.getParam(SEARCH_STRING, false);

        if (!StringUtils.isBlank(searchString)) {
            log.info("SystemSearchSetupAction.getResult() calling performSearch()");
            return performSearch(context);
        }
        log.info("SystemSearchSetupAction.getResult() returning Collections.EMPTY_LIST");
        return Collections.EMPTY_LIST;
    }

    /** {@inheritDoc} */
    public String getParentUrl(RequestContext context) {
        return context.getRequest().getRequestURI();
    }

}
