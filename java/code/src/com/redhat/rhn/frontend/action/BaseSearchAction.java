/**
 * Copyright (c) 2013 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action;

import java.net.MalformedURLException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.rhnpackage.MissingArchitectureException;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;

/**
 * Base action for searches - this is a place to put the 'magic strings' that connect the
 * JSP forms and pages to the action, and to impose a certain amount of uniformity on
 * our (currently-very-non-uniform) search processing.
 *
 * @author ggainey
 *
 */
public abstract class BaseSearchAction extends RhnAction {
    protected static Logger log = Logger.getLogger(BaseSearchAction.class);

    /** Channel-arches a default package-search should look in */
    public static final String[] DEFAULT_ARCHES = {
        "channel-ia32", "channel-ia64",
        "channel-x86_64",
        "channel-s390",
        "channel-s390x",
        "channel-ppc",
        "channel-sparc-sun-solaris", "channel-i386-sun-solaris" };

    /** List of channel arches we don't really support any more. */
    public static final List<String> EXCLUDED_ARCHES = Arrays.asList(new String[]
        {"channel-sparc", "channel-alpha", "channel-iSeries", "channel-pSeries"});

    // combinedSearchForm common keys
    public static final String FINE_GRAINED = "fineGrained";
    public static final String SEARCH_STR = "search_string";
    public static final String VIEW_MODE = "view_mode";
    public static final String SEARCH_OPT = "searchOptions";

    // Package-specific keys
    public static final String ALL_CHANNELS = "allChannels";
    public static final String ARCHITECTURE = "architecture";
    public static final String CHANNEL = "channel";
    public static final String CHANNEL_ARCH = "channel_arch";
    public static final String CHANNEL_ARCHES = "channelArches";
    public static final String CHANNEL_FILTER = "channel_filter";
    public static final String OPT_FREE_FORM = "search_free_form";
    public static final String OPT_NAME_AND_DESC = "search_name_and_description";
    public static final String OPT_NAME_AND_SUMMARY = "search_name_and_summary";
    public static final String OPT_NAME_ONLY = "search_name";
    public static final String RELEVANT = "relevant";
    public static final String WHERE_CRITERIA = "whereCriteria";

    // Errata-specific keys
    public static final String OPT_ISSUE_DATE = "optionIssueDateSearch";
    public static final String OPT_ADVISORY = "errata_search_by_advisory";
    public static final String OPT_PKG_NAME = "errata_search_by_package_name";
    public static final String OPT_CVE = "errata_search_by_cve";
    public static final String OPT_ALL_FIELDS = "errata_search_by_all_fields";
    public static final String ERRATA_BUG = "errata_type_bug";
    public static final String ERRATA_SEC = "errata_type_security";
    public static final String ERRATA_ENH = "errata_type_enhancement";

    // Doc-specific keys
    public static final String OPT_CONTENT_ONLY = "search_content";
    public static final String OPT_TITLE_ONLY = "search_title";
    public static final String OPT_CONTENT_TITLE = "search_content_title";

    // System-specific keys
    public static final String OPT_GROUPS_MAP = "optGroupsMap";
    public static final String OPT_GROUPS_KEYS = "optGroupsKeys";
    public static final String WHERE_TO_SEARCH = "whereToSearch";
    public static final String INVERT_RESULTS = "invert";
    public static final String WHERE_ALL = "all";
    public static final String WHERE_SSM = "system_list";

    //Xcddf-specific keys
    public static final String SCAN_DATE_SEARCH = "optionScanDateSearch";

    // addOption keys
    public static final String DISPLAY_KEY = "display";
    public static final String VALUE_KEY = "value";

    /**
     * {@inheritDoc}
     * The default execute() workflow for search-related actions is to call executeBody(),
     * handle any execptions thrown, and return whatever destination executeBody returned.
     */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        ActionErrors errors = new ActionErrors();
        DynaActionForm form = (DynaActionForm)formIn;
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        String searchString = form.getString(BaseSearchAction.SEARCH_STR);
        ActionForward destination = mapping.findForward(RhnHelper.DEFAULT_FORWARD);

        try {
            // handle setup, the submission setups the searchstring below
            // and redirects to this page which then performs the search.
            destination = executeBody(request, mapping, form);
        }
        catch (XmlRpcException xre) {
            log.error("Could not connect to search server.", xre);
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("packages.search.connection_error"));
        }
        catch (XmlRpcFault e) {
            log.info("Caught Exception :" + e + ", code [" + e.getErrorCode() + "]");
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
        catch (MissingArchitectureException mae) {
            errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    "packages.search.need_one_arch"));
        }

        if (!errors.isEmpty()) {
            addErrors(request, errors);
        }

        return destination;
    }

    /**
     * This method invokes insureFormDefaults(), followed by doExecute().  Child classes
     * are expected to do "reasonable" things in those methods.
     * @param request http request
     * @param mapping action mapping
     * @param form associated form
     * @return expected destination from doExecute
     * @throws MalformedURLException
     * @throws XmlRpcFault
     */
    protected ActionForward executeBody(HttpServletRequest request, ActionMapping mapping,
                        DynaActionForm form)
    throws MalformedURLException, XmlRpcFault {
        insureFormDefaults(request, form);
        return doExecute(request, mapping, form);
    }

    /**
     * This is the guts of a search action - do what needs doing,
     * and return what you think the next page should be
     * @param request incoming HTTP request
     * @param mapping incoming action-mapping
     * @param form form associated with this mapping
     * @return the desired desitination based on your processing
     * @throws MalformedURLException
     * @throws XmlRpcFault
     */
    protected abstract ActionForward doExecute(HttpServletRequest request,
                    ActionMapping mapping,
                    DynaActionForm form)
                    throws MalformedURLException, XmlRpcFault;

    /**
     * This gives the child-actions a chance to set up sane defaults no matter how
     * the happen to be invoked.  Set up the form here, so that it can be relied on
     * by code later in the workflow.
     *
     * @param request incoming HTTP request
     * @param form form associated with the request
     */
    protected abstract void insureFormDefaults(HttpServletRequest request,
                    DynaActionForm form);

    /**
     * Utility function to create options for the dropdown.
     * @param options list containing all options.
     * @param key resource bundle key used as the display value.
     * @param value value to be submitted with form.
     */
    protected void addOption(List<Map<String, String>> options, String key, String value) {
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
    public void addOption(List<Map<String, String>> options, String key, String value,
                    boolean flag) {
        LocalizationService ls = LocalizationService.getInstance();
        Map<String, String> selection = new HashMap<String, String>();
        selection.put("display", (flag ? "*" : "") + ls.getMessage(key));
        selection.put("value", StringEscapeUtils.escapeHtml(value));
        options.add(selection);
    }

}
