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
package com.redhat.rhn.frontend.action.systems;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.taglibs.list.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListSubmitable;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
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

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcFault;

import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SystemSearchAction extends RhnAction - Class representation of the table ###TABLE###.
 * @version $Rev: 1 $
 */
public class SystemSearchSetupAction extends RhnAction implements ListSubmitable {
    private static Logger log = Logger.getLogger(SystemSearchSetupAction.class);

    public static final String LIST_NAME = "pageList";
    public static final String DATA_SET = "searchResults";
    public static final String CACHED_DATA_NAME = "cachedSearchResults";
    
    public static final String NAME_AND_DESCRIPTION =
        "systemsearch_name_and_description";
    public static final String ID = "systemsearch_id";
    public static final String CUSTOM_INFO = "systemsearch_custom_info";
    public static final String SNAPSHOT_TAG = "systemsearch_snapshot_tag";
    public static final String CHECKIN = "systemsearch_checkin";
    public static final String REGISTERED = "systemsearch_registered";
    public static final String CPU_MODEL = "systemsearch_cpu_model";
    public static final String CPU_MHZ_LT = "systemsearch_cpu_mhz_lt";
    public static final String CPU_MHZ_GT = "systemsearch_cpu_mhz_gt";
    public static final String NUM_CPUS_LT = "systemsearch_num_of_cpus_lt";
    public static final String NUM_CPUS_GT = "systemsearch_num_of_cpus_gt";
    public static final String RAM_LT = "systemsearch_ram_lt";
    public static final String RAM_GT = "systemsearch_ram_gt";
    public static final String HW_DESCRIPTION = "systemsearch_hwdevice_description";
    public static final String HW_DRIVER = "systemsearch_hwdevice_driver";
    public static final String HW_DEVICE_ID = "systemsearch_hwdevice_device_id";
    public static final String HW_VENDOR_ID = "systemsearch_hwdevice_vendor_id";
    public static final String DMI_SYSTEM = "systemsearch_dmi_system";
    public static final String DMI_BIOS = "systemsearch_dmi_bios";
    public static final String DMI_ASSET = "systemsearch_dmi_asset";
    public static final String HOSTNAME = "systemsearch_hostname";
    public static final String IP = "systemsearch_ip";
    public static final String INSTALLED_PACKAGES = "systemsearch_installed_packages";
    public static final String NEEDED_PACKAGES = "systemsearch_needed_packages";
    public static final String LOC_ADDRESS = "systemsearch_location_address";
    public static final String LOC_BUILDING = "systemsearch_location_building";
    public static final String LOC_ROOM = "systemsearch_location_room";
    public static final String LOC_RACK = "systemsearch_location_rack";
    
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
                                     {  NAME_AND_DESCRIPTION,
                                        ID,
                                        CUSTOM_INFO,
                                        SNAPSHOT_TAG
                                     },
                                     /* activity group */
                                     {  CHECKIN,
                                         REGISTERED
                                     },
                                     /* hardware group */
                                     {
                                        CPU_MODEL,
                                        CPU_MHZ_LT,
                                        CPU_MHZ_GT,
                                        NUM_CPUS_LT,
                                        NUM_CPUS_GT,
                                        RAM_LT,
                                        RAM_GT
                                     },
                                     /* device group */
                                     {  HW_DESCRIPTION,
                                        HW_DRIVER,
                                        HW_DEVICE_ID,
                                        HW_VENDOR_ID
                                     },
                                     /* dmiinfo */
                                     {
                                        DMI_SYSTEM,
                                        DMI_BIOS,
                                        DMI_ASSET
                                     },
                                     /* network info */
                                     {
                                         HOSTNAME,
                                         IP
                                     },
                                     /* packages */
                                     {
                                        INSTALLED_PACKAGES,
                                        NEEDED_PACKAGES
                                     },
                                     /* location */
                                     {
                                        LOC_ADDRESS,
                                        LOC_BUILDING,
                                        LOC_ROOM,
                                        LOC_RACK
                                     }};
    
    public static final String SEARCH_STRING = "search_string";
    public static final String VIEW_MODE = "view_mode";
    public static final String WHERE_TO_SEARCH = "whereToSearch";
    public static final String INVERT_RESULTS = "invert";

    private static final String FORM = "FORM";
    private static final String MAPPING = "MAPPING";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) 
                                 throws BadParameterException {
        
        
        DynaActionForm daForm = (DynaActionForm) formIn;
        request.setAttribute(FORM, daForm);
        request.setAttribute(MAPPING, mapping);
        
        if (isSubmitted(daForm)) {
            String searchString = daForm.getString(SEARCH_STRING);
            String viewMode = daForm.getString(VIEW_MODE);
            String whereToSearch = daForm.getString(WHERE_TO_SEARCH);
            Boolean invertResults = (Boolean) daForm.get(INVERT_RESULTS);

            setupForm(request, daForm, viewMode);
            if (whereToSearch == null || viewMode == null) {
                throw new BadParameterException("An expected form var was null");
            }
            
            request.setAttribute(SEARCH_STRING, searchString);
            request.setAttribute(VIEW_MODE, viewMode);
            request.setAttribute(INVERT_RESULTS, invertResults);
            request.setAttribute(WHERE_TO_SEARCH, whereToSearch);
            ActionErrors errs = new ActionErrors();
            if (viewMode.equals("systemsearch_id") ||
                    viewMode.equals("systemsearch_cpu_mhz_lt") ||
                    viewMode.equals("systemsearch_cpu_mhz_gt") ||
                    viewMode.equals("systemsearch_ram_lt") ||
                    viewMode.equals("systemsearch_ram_gt") ||
                    viewMode.equals("systemsearch_num_of_cpus_lt") ||
                    viewMode.equals("systemsearch_num_of_cpus_gt") ||
                    viewMode.equals("systemsearch_checkin") ||
                    viewMode.equals("systemsearch_registered")) {
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
                  }
        }
        else {
            setupForm(request, daForm, null);
            request.setAttribute(VIEW_MODE, "systemsearch_name_and_description");
            daForm.set(WHERE_TO_SEARCH, "all");
        }

        ListRhnSetHelper helper = new ListRhnSetHelper(this);
        return helper.execute(mapping, formIn, request, response);
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
        ActionMapping mapping = (ActionMapping) request.getAttribute(MAPPING);
        DynaActionForm daForm = (DynaActionForm) request.getAttribute(FORM);
        String searchString = daForm.getString(SEARCH_STRING);
        String viewMode = daForm.getString(VIEW_MODE);
        String whereToSearch = daForm.getString(WHERE_TO_SEARCH);
        Boolean invertResults = (Boolean) daForm.get(INVERT_RESULTS);

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
            e.printStackTrace();
            if (e.getErrorCode() == 100) {
                log.error("Invalid search query", e);
            }
            errs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("packages.search.could_not_parse_query",
                                      searchString));
        }
        catch (XmlRpcException e) {
            log.info("Caught Exception :" + e);
            e.printStackTrace();
            errs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("packages.search.connection_error"));
        }
        if (dr == null) {
            request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
            request.setAttribute(RequestContext.PAGE_LIST, dr);
            ActionMessages messages = new ActionMessages();
            messages.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("systemsearch_no_matches_found"));
            getStrutsDelegate().saveMessages(request, messages);
        }
        /*
        if (dr.size() == 1) {
            SystemSearchResult s =  (SystemSearchResult) dr.get(0);
            try {
                response.sendRedirect("/rhn/systems/details/Overview.do?sid=" +
                        s.getId().toString());
                return null;
            }
            catch (IOException ioe) {
                throw new RuntimeException(
                        "Exception while trying to redirect: " + ioe);
            }
        }
        */
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
        Map selection = new HashMap();
        selection.put("display", display);
        selection.put("value", value);
        return selection;
    }

    /**
     * {@inheritDoc}
     */
    public String getListName()  {
        return LIST_NAME;
    }

    /**
     * {@inheritDoc}
     */
    public String getDataSetName() {
        return DATA_SET;
    }

    /**
     * {@inheritDoc}
     */
    public  String getDecl(RequestContext context) {
        return RhnSetDecl.SYSTEMS.getLabel();
    }

    /**
     * {@inheritDoc}
     */
    public List getResult(RequestContext context) {
        /*String cachedName = makeKey(context);
        List result = (List)context.getRequest().getSession().getAttribute(cachedName);
        if (result != null) {
            return result;
        }*/

        DynaActionForm daForm = (DynaActionForm) context.getRequest().getAttribute(FORM);
        String searchString = daForm.getString(SEARCH_STRING);
        String viewMode = daForm.getString(VIEW_MODE);
        String whereToSearch = daForm.getString(WHERE_TO_SEARCH);
        Boolean invertResults = (Boolean) daForm.get(INVERT_RESULTS);

        if (!StringUtils.isBlank(searchString)) {
            log.info("SystemSearchSetupAction.getResult() calling performSearch()");
            return performSearch(context);
        }
        log.info("SystemSearchSetupAction.getResult() returning Collections.EMPTY_LIST");
        return Collections.EMPTY_LIST;
    }

    private String makeKey(RequestContext context) {
        DynaActionForm daForm = (DynaActionForm) context.getRequest().getAttribute(FORM);
        String searchString = daForm.getString(SEARCH_STRING);
        String viewMode = daForm.getString(VIEW_MODE);
        String whereToSearch = daForm.getString(WHERE_TO_SEARCH);
        Boolean invertResults = (Boolean) daForm.get(INVERT_RESULTS);

        return StringUtil.toJson(new Object [] {
                searchString, viewMode, whereToSearch, invertResults
        });
    }

    /**
     * {@inheritDoc}
     */
    public ActionForward  handleDispatch(ActionMapping mapping,
                            ActionForm formIn, HttpServletRequest request,
                            HttpServletResponse response) {
        return null;
    }

    /**
     * {@inheritDoc}
     */
    public String getParentUrl(RequestContext context) {
        return context.getRequest().getRequestURI();
    }

}
