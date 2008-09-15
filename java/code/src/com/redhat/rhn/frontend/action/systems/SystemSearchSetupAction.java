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
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.dto.SystemSearchResult;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.io.IOException;
import java.util.ArrayList;
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
                           
public class SystemSearchSetupAction extends RhnListAction {
    
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
                                     {  "systemsearch_name_and_description",
                                        "systemsearch_id",
                                        "systemsearch_custom_info",
                                        "systemsearch_snapshot_tag"
                                     },
                                     /* activity group */
                                     {  "systemsearch_checkin",
                                        "systemsearch_registered"
                                     },
                                     /* hardware group */
                                     {
                                        "systemsearch_cpu_model",
                                        "systemsearch_cpu_mhz_lt",
                                        "systemsearch_cpu_mhz_gt",
                                        "systemsearch_ram_lt",
                                        "systemsearch_ram_gt"
                                     },
                                     /* device group */
                                     {  "systemsearch_hwdevice_description",
                                        "systemsearch_hwdevice_driver",
                                        "systemsearch_hwdevice_device_id",
                                        "systemsearch_hwdevice_vendor_id"
                                     },
                                     /* dmiinfo */
                                     {
                                        "systemsearch_dmi_system",
                                        "systemsearch_dmi_bios",
                                        "systemsearch_dmi_asset"
                                     },
                                     /* network info */
                                     {
                                         "systemsearch_hostname",
                                         "systemsearch_ip"
                                     },
                                     /* packages */
                                     {
                                        "systemsearch_installed_packages",
                                        "systemsearch_needed_packages"
                                     },
                                     /* location */
                                     {
                                        "systemsearch_location_address",
                                        "systemsearch_location_building",
                                        "systemsearch_location_room",
                                        "systemsearch_location_rack"
                                     }};
    
    public static final String SEARCH_STRING = "search_string";
    public static final String VIEW_MODE = "view_mode";
    public static final String WHERE_TO_SEARCH = "whereToSearch";
    public static final String INVERT_RESULTS = "invert";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) 
                                 throws BadParameterException {
        
        RequestContext requestContext = new RequestContext(request);
        
        DynaActionForm daForm = (DynaActionForm) formIn;
        User user = requestContext.getLoggedInUser();
        RhnSet set = getSetDecl().get(user);
        request.setAttribute("set", set);
        
        PageControl pc = new PageControl();
        clampListBounds(pc, request, user);
        
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
                 
                 if (errs.size() > 0) {
                     getStrutsDelegate().saveMessages(request, errs);
                     request.setAttribute(SEARCH_STRING, null);
                     return mapping.findForward("error");
                 }
                if (viewMode.equals("systemsearch_dmi_asset")) {
                    searchString = "chassis: " + searchString;
                }
                DataResult dr = SystemManager.systemSearch(user, 
                        searchString, 
                        viewMode, 
                        invertResults, 
                        whereToSearch, 
                        pc);
                
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
                
                request.setAttribute(RequestContext.PAGE_LIST, dr);
        }
        else {
           setupForm(request, daForm, null);
           request.setAttribute(VIEW_MODE, "systemsearch_name_and_description");
           daForm.set(WHERE_TO_SEARCH, "all");
        }
        
        return mapping.findForward("default");
    }
    
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.SYSTEMS;
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
}
