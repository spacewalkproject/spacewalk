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
package com.redhat.rhn.frontend.action.systems;

import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcFault;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.action.BaseSearchAction;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.dto.SystemSearchResult;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

/**
 * Action handling the advanced system search page.
 */
public class SystemSearchAction extends BaseSearchAction implements Listable {

    public static final String DATA_SET = "searchResults";

    public static final String[] OPT_GROUPS_TITLES = {"systemsearch.jsp.details",
        "systemsearch.jsp.activity",
        "systemsearch.jsp.hardware",
        "systemsearch.jsp.devices",
        "systemsearch.jsp.dmiinfo",
        "systemsearch.jsp.networkinfo",
        "systemsearch.jsp.packages",
        "systemsearch.jsp.location"};

    public static final String[][] OPT_GROUPS = {
                    /* details */
                    { SystemSearchHelper.NAME_AND_DESCRIPTION, SystemSearchHelper.ID,
                                    SystemSearchHelper.CUSTOM_INFO,
                                    SystemSearchHelper.SNAPSHOT_TAG,
                                    SystemSearchHelper.RUNNING_KERNEL,
                                    SystemSearchHelper.UUID },
                    /* activity group */
                    { SystemSearchHelper.CHECKIN, SystemSearchHelper.REGISTERED },
                    /* hardware group */
                    { SystemSearchHelper.CPU_MODEL, SystemSearchHelper.CPU_MHZ_LT,
                                    SystemSearchHelper.CPU_MHZ_GT,
                                    SystemSearchHelper.NUM_CPUS_LT,
                                    SystemSearchHelper.NUM_CPUS_GT,
                                    SystemSearchHelper.RAM_LT, SystemSearchHelper.RAM_GT },
                    /* device group */
                    { SystemSearchHelper.HW_DESCRIPTION, SystemSearchHelper.HW_DRIVER,
                                    SystemSearchHelper.HW_DEVICE_ID,
                                    SystemSearchHelper.HW_VENDOR_ID },
                    /* dmiinfo */
                    { SystemSearchHelper.DMI_SYSTEM, SystemSearchHelper.DMI_BIOS,
                                    SystemSearchHelper.DMI_ASSET },
                    /* network info */
                    { SystemSearchHelper.HOSTNAME, SystemSearchHelper.IP,
                                    SystemSearchHelper.IP6 },
                    /* packages */
                    { SystemSearchHelper.INSTALLED_PACKAGES,
                                    SystemSearchHelper.NEEDED_PACKAGES },
                    /* location */
                    { SystemSearchHelper.LOC_ADDRESS, SystemSearchHelper.LOC_BUILDING,
                                    SystemSearchHelper.LOC_ROOM,
                                    SystemSearchHelper.LOC_RACK } };

    public static final List<String> VALID_WHERE_STRINGS =
                    Arrays.asList(new String[] {WHERE_ALL, WHERE_SSM});

    private final Logger log = Logger.getLogger(SystemSearchAction.class);

    @Override
    protected void insureFormDefaults(HttpServletRequest request, DynaActionForm form) {
        String search = form.getString(SEARCH_STR).trim();
        String where = form.getString(WHERE_TO_SEARCH);
        String viewMode = form.getString(VIEW_MODE);

        if (where == null || viewMode == null) {
            throw new BadParameterException("An expected form var was null");
        }

        if ("".equals(viewMode)) { // first time viewing page
            viewMode = "systemsearch_name_and_description";
            form.set(VIEW_MODE, viewMode);
            request.setAttribute(VIEW_MODE, viewMode);
        }

        if ("".equals(where) || !VALID_WHERE_STRINGS.contains(where)) {
            form.set(WHERE_TO_SEARCH, "all");
            request.setAttribute(WHERE_TO_SEARCH, "all");
        }

        Boolean fineGrained = (Boolean)form.get(FINE_GRAINED);
        request.setAttribute(FINE_GRAINED, fineGrained == null ? false : fineGrained);

        Boolean invert = (Boolean) form.get(INVERT_RESULTS);
        if (invert == null) {
            invert = Boolean.FALSE;
            form.set(INVERT_RESULTS, invert);
        }

        if (invert) {
            request.setAttribute(INVERT_RESULTS, "on");
        }
        else {
            request.setAttribute(INVERT_RESULTS, "off");
        }

        /* Here we set up a hashmap using the string resources key for the various options
         * group as a key into the hash, and the string resources/database mode keys as
         * the values of the options that are contained within each opt group. The jsp
         * uses this hashmap to setup a dropdown box
         */
        boolean matchingViewModeFound = false;
        Map<String, List<Map<String, String>>> optGroupsMap =
                        new HashMap<String, List<Map<String, String>>>();
        LocalizationService ls = LocalizationService.getInstance();
        for (int j = 0; j < OPT_GROUPS_TITLES.length; ++j) {
            List<Map<String, String>> options = new ArrayList<Map<String, String>>();

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
        request.setAttribute(OPT_GROUPS_MAP, optGroupsMap);
        request.setAttribute(OPT_GROUPS_KEYS, optGroupsMap.keySet());
        request.setAttribute(SEARCH_STR, search);
        request.setAttribute(VIEW_MODE, viewMode);
        request.setAttribute(WHERE_TO_SEARCH, where);
    }

   protected ActionForward doExecute(HttpServletRequest request, ActionMapping mapping,
                   DynaActionForm form) {
        String viewMode = form.getString(VIEW_MODE);
        String searchString = form.getString(SEARCH_STR).trim();

        ActionErrors errs = new ActionErrors();
        if (viewMode.equals(SystemSearchHelper.ID) ||
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

            // TODO: Set up combined-form validator
//              errs.add(RhnValidationHelper.validateDynaActionForm(this, daForm));
        addErrors(request, errs);

        ListRhnSetHelper helper = new ListRhnSetHelper(this, request, RhnSetDecl.SYSTEMS);
        helper.setWillClearSet(false);
        helper.setDataSetName(getDataSetName());
        helper.setListName(getListName());
        helper.execute();

        List results = (List) request.getAttribute(getDataSetName());
        log.debug("SystemSearch results.size() = " +
                        (results != null ? results.size() : "null results"));
        if ((results != null) && (results.size() == 1)) {
            SystemSearchResult s = (SystemSearchResult) results.get(0);
            return StrutsDelegate.getInstance().forwardParam(mapping.findForward("single"),
                            "sid", s.getId().toString());
        }
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    protected DataResult performSearch(RequestContext context) {
        HttpServletRequest request = context.getRequest();
        String searchString = (String)request.getAttribute(SEARCH_STR);
        String viewMode = (String)request.getAttribute(VIEW_MODE);
        String whereToSearch = (String)request.getAttribute(WHERE_TO_SEARCH);
        Boolean invertResults = StringUtils.defaultString(
                        (String)request.getAttribute(INVERT_RESULTS)).equals("on");
        Boolean isFineGrained = (Boolean)request.getAttribute(FINE_GRAINED);

        ActionErrors errs = new ActionErrors();
        DataResult dr = null;
        try {
            dr = SystemSearchHelper.systemSearch(context,
                    searchString,
                    viewMode,
                    invertResults,
                    whereToSearch, isFineGrained);
        }
        catch (MalformedURLException e) {
            log.error("Caught Exception :" + e, e);
            errs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("packages.search.connection_error"));
        }
        catch (XmlRpcFault e) {
            log.info("Caught Exception :" + e + ", code [" + e.getErrorCode() + "]", e);
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
            log.error("Caught Exception :" + e, e);
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

    /** {@inheritDoc} */
    private String getListName()  {
        return RequestContext.PAGE_LIST;
    }

    /** {@inheritDoc} */
    private String getDataSetName() {
        return DATA_SET;
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
    public List getResult(RequestContext context) {
        String searchString = (String)context.getRequest().getAttribute(SEARCH_STR);

        if (!StringUtils.isBlank(searchString)) {
            log.debug("SystemSearchSetupAction.getResult() calling performSearch()");
            return performSearch(context);
        }
        log.debug("SystemSearchSetupAction.getResult() returning Collections.EMPTY_LIST");
        return Collections.emptyList();
    }

}
