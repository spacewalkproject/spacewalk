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

package com.redhat.rhn.frontend.taglibs.list;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.taglibs.list.decorators.ExtraButtonDecorator;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.lang.StringUtils;

import java.io.IOException;
import java.io.Writer;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.BodyTagSupport;
import javax.servlet.jsp.tagext.Tag;

/**
 * Provides various utility functions for the ListTag, ColumnTag, and SpanTag
 *
 * @version $Rev $
 */
public class ListTagUtil {
    private static final String HIDDEN_TEXT = "<input type=\"hidden\" " +
                                                "name=\"%s\" value=\"%s\"/>";
    private static final String IE_MAGIC_SNIPPET = "<!--[if IE]><input type=\"text\" " +
            "style=\"display: none;\" disabled=\"disabled\" size=\"1\" /><![endif]-->";

    private ListTagUtil() {

    }


    /**
     * Increments a "persistent" counter. These counters are used by column tags
     * to track and increment values across column render passes.
     * @param ctx active PageContext
     * @param name name of counter
     * @return next value
     */
    public static Long incrementPersistentCounter(PageContext ctx, String name) {
        Long counter = (Long) ctx.getRequest().getAttribute(name);
        if (counter == null) {
            counter = new Long(1);
        }
        else {
            counter = new Long(counter.longValue() + 1);
        }
        ctx.getRequest().setAttribute(name, counter);
        return counter;
    }

    /**
     * Clears a "persistent" counter.
     * @param ctx active PageContext
     * @param name name of counter
     */
    public static void clearPersistentCounter(PageContext ctx, String name) {
        ctx.removeAttribute(name);
    }

    /**
     * Gets the current value of a "persistent" counter
     * @param ctx active PageContext
     * @param name name of counter
     * @return current value if counter exists, else -1
     */
    public static long getPersistentCounterValue(PageContext ctx, String name) {
        long retval = -1;
        Long counter = (Long) ctx.getAttribute(name);
        if (counter != null) {
            retval = counter.longValue();
        }
        return retval;
    }

    /**
     * Locates the current ListCommand
     * @param caller tag calling the method
     * @param ctx caller's page context
     * @return ListCommand if found, otherwise null
     */
    public static ListCommand getCurrentCommand(Tag caller, PageContext ctx) {
        ListTag parent = null;
        if (!(caller instanceof ListTag)) {
            parent = (ListTag) BodyTagSupport.findAncestorWithClass(caller, ListTag.class);
        }
        else {
            parent = (ListTag) caller;
        }
        if (parent != null) {
            return (ListCommand) ctx.getAttribute(parent.getUniqueName() + "_cmd");
        }
        else {
            return null;
        }
    }

    /**
     * Stores a ListCommand in the page context and makes it current
     * @param ctx caller's page context
     * @param uniqueName owning list's unique name
     * @param cmd new current command
     */
    public static void setCurrentCommand(PageContext ctx, String uniqueName,
            ListCommand cmd) {
        ctx.setAttribute(uniqueName + "_cmd", cmd);
    }

    /**
     * Builds URL for the filter form
     * @param request current request
     * @param listName unique list name
     * @return url pointing to this list
     */
    public static String makeFilterFormUrl(HttpServletRequest request, String listName) {
        return makeNonPagedLink(request, listName);
    }

    /**
     * Writes arbitrary text to the client (browser)
     * @param ctx caller's page context
     * @param text text to write
     * @throws JspException if an error occurs
     */
    public static void write(PageContext ctx, String text) throws JspException {
        if (text == null) {
            text = "null";
        }
        Writer writer = ctx.getOut();
        try {
            writer.write(text);
        }
        catch (IOException e) {
            throw new JspException(e);
        }
    }

    /**
     * Returns a link containing the URL + ALL the parameters of the
     * request query string minus the sort links, and the alpha link +
     * the additional params passed in the paramsToAdd map.
     *
     * @param request the Servlet Request
     * @param listName the current list name
     * @param paramsToAdd the params you might want to append to the url
     *                  for example makeSortLink passes in sortByLabel
     *                  while alpha bar passes in params that are specific to it.
     *  @param paramsToIgnore params to not include that would be normally
     * @return a link containing the URL  + (OtherParams - Sort - Alpha) + paramsToAdd
     */
    public static String makeParamsLink(ServletRequest request,
                                        String listName,
                                        Map<String, String> paramsToAdd,
                                        List<String> paramsToIgnore) {
        String url = (String) request.getAttribute(ListTagHelper.PARENT_URL);
        String sortByLabel = makeSortByLabel(listName);
        String sortByDir =   makeSortDirLabel(listName);
        String alphaKey =   AlphaBarHelper.makeAlphaKey(listName);
        StringBuilder params = new StringBuilder();
        if (url.indexOf('?') < 0) {
            params.append("?");
        }
        else if (url.indexOf('?') != url.length() - 1) {
            params.append("&");
        }

        for (Enumeration<String> en = request.getParameterNames(); en.hasMoreElements();) {
            String paramName = en.nextElement();
            if (!sortByLabel.equals(paramName) && !sortByDir.equals(paramName) &&
                    !alphaKey.equals(paramName) && !paramsToIgnore.contains(paramName)) {
                if (params.length() > 1) {
                    params.append("&");
                }
                params.append(paramName).append("=")
                            .append(StringUtil.urlEncode(request.getParameter(paramName)));
            }
        }
        for (String key : paramsToAdd.keySet()) {
            if (params.length() > 1) {
                params.append("&");
            }
            params.append(key).append("=")
                        .append(paramsToAdd.get(key));
        }

        return url + params.toString();
    }

    /**
     * Builds sort link
     * @param request current request
     * @param listName list's unique name
     * @param attrName attribute to sort on
     * @param sortDir sort direction: RequestContext.SORT_ASC for ascending,
     *           RequestContext.SORT_DESC for descending
     * @return link
     */
    public static String makeColumnSortLink(HttpServletRequest request,
            String listName, String attrName, String sortDir) {
        String sortById = ListTagUtil.makeSortById(listName);
        String sortDirId = ListTagUtil.makeSortDirId(listName);

        String js = "sortColumn('%s', '%s', '%s', '%s')";
        if (StringUtils.isBlank(sortDir)) {
            sortDir = RequestContext.SORT_ASC;
        }
        else if (sortDir.equals(RequestContext.SORT_ASC)) {
            sortDir = RequestContext.SORT_DESC;
        }
        else {
            sortDir = RequestContext.SORT_ASC;
        }

        return String.format(js, sortById, attrName, sortDirId, sortDir);
    }

    /**
     * provides the sort direction url key
     * @param listName the name of the list
     * @return the url key for sort direction
     */
    public static String makeSortDirLabel(String listName) {
        return "list_" + listName + "_sortdir";
    }

    /**
     * provides the sort label (what to sort by) url key
     * @param listName the list name
     * @return the url key for sort label
     */
    public static String makeSortByLabel(String listName) {
        return "list_" + listName + "_sortby";
    }

    /**
     * provides the sort direction url key
     * @param listName the name of the list
     * @return the url key for sort direction
     */
    public static String makeSortDirId(String listName) {
        return "list_" + listName + "_sortdir_id";
    }

    /**
     * provides the sort label (what to sort by) url key
     * @param listName the list name
     * @return the url key for sort label
     */
    public static String makeSortById(String listName) {
        return "list_" + listName + "_sortby_id";
    }

    /**
     * provides the filter label (what to sort by) url key
     * @param listName the list name
     * @return the url key for filter label
     */
    public static String makeFilterByLabel(String listName) {
        return "list_" + listName + "_filterby";
    }

    /**
     * provides the filter label (what to sort by) url key
     * @param listName the list name
     * @return the url key for filter value label
     */
    public static String makeFilterValueByLabel(String listName) {
        return "list_" + listName + "_filterval";
    }

    /**
     * provides the filter label on the boolean search parent
     * @param listName the list name
     * @return the url key for filter value label
     */
    public static String makeFilterSearchParentLabel(String listName) {
        return "list_" + listName + "_search_parent";
    }

    /**
     * provides the filter label on the boolean search child
     * @param listName the list name
     * @return the url key for filter value label
     */
    public static String makeFilterSearchChildLabel(String listName) {
        return "list_" + listName + "_search_child";
    }


    /**
     * provides the filter label (what to sort by) url key
     * @param listName the list name
     * @return the url key for filter value label
     */
    public static String makeFilterAttributeByLabel(String listName) {
        return "list_" + listName + "_filterattr";
    }


    /**
     * provides the filter label (what to sort by) url key
     * @param listName the list name
     * @return the url key for filter value label
     */
    public static String makeImageNameByLabel(String listName) {
        return "list_" + listName + "_filterattr";
    }


    /**
     * provides the filter name (the name value for the go button on the filter box)
     * @param listName the list name
     * @return the key for filter name label
     */
    public static String makeFilterNameByLabel(String listName) {
        return "list_" + listName + "_filtername";
    }

    /**
     * provides the filter label (what to sort by) url key
     * @param listName the list name
     * @return the url key for filter value label
     */
    public static String makeOldFilterValueByLabel(String listName) {
        return "list_" + listName + "_oldfilterval";
    }

    /**
     * provides the label to set/get the filter class
     * @param listName the list name
     * @return the filter class label
     */
    public static String makeFilterClassLabel(String listName) {
        return "list_" + listName + "_filterclass";
    }

    /**
     * Returns the name of the Select Action attribute
     * For example the Select All, Unselect All and Update buttons
     * use this name..
     * @param listName the name of the table tag
     * @return the label of the select action
     */
    public static String makeSelectActionName(String listName) {
        return "list_" + listName + "_selectAction";
    }

    /**
     * Returns the name of the extra buttonattribute
     * @param listName the name of the table tag
     * @return the label of the select action
     */
    public static String makeExtraButtonName(String listName) {
        return "list_" + listName + "_" + ExtraButtonDecorator.EXTRA_BUTTON;
    }



    /**
     * Returns the name of the attribute that holds the selected amount
     * @param listName the list name
     * @return the label of the select amount attribute
     */
    public static String makeSelectedAmountName(String listName) {
        return "list_" + listName + "_selected_amt";
    }

    /**
     * Returns the name of the attribute that holds the selected check box items
     * @param listName the list name
     * @return the name of selected items
     */
    public static String makeSelectedItemsName(String listName) {
        return "list_" + listName + "_sel";
    }

    /**
     * Returns the name of the attribute that holds the all the row items on the page.
     * @param listName the list name
     * @return the name of attribute holding all the row items in the page
     */
    public static String makePageItemsName(String listName) {
        return "list_" + listName + "_items";
    }

    /**
     * Returns the name of the attribute that holds the current page number.
     * @param listName the list name
     * @return the  name of the attribute that holds the current page number.
     */
    public static String makePageNumberName(String listName) {
        return "list_" + listName + "_page";
    }
    /**
     * Make first page link
     * @param request current request
     * @param listName list unique name
     * @return url
     */
    public static String makeFirstPageLink(HttpServletRequest request, String listName) {
        return makePageLink(request, listName, "first");
    }

    /**
     * Make last page link
     * @param request current request
     * @param listName list unique name
     * @return url
     */
    public static String makeLastPageLink(HttpServletRequest request, String listName) {
        return makePageLink(request, listName, "last");
    }

    /**
     * Make prev page link
     * @param request current request
     * @param listName list unique name
     * @param currentPage current page #
     * @return url
     */

    public static String makePrevPageLink(HttpServletRequest request, String listName,
            int currentPage) {
        return makePageLink(request, listName, String.valueOf(currentPage - 1));
    }

    /**
     * Make next page link
     * @param request current request
     * @param listName list unique name
     * @param currentPage current page #
     * @return url
     */
    public static String makeNextPageLink(HttpServletRequest request, String listName,
            int currentPage) {
        return makePageLink(request, listName, String.valueOf(currentPage + 1));
    }

    /**
     * Gets the value of a data bean attribute
     * @param bean target
     * @param attribute attribute name - should be in Java bean notation
     * @return String value, null if no value
     */
    public static String getBeanValue(Object bean, String attribute) {
        try {
            return BeanUtils.getProperty(bean, attribute);
        }
        catch (Exception e) {
            String msg = String.format("Exception encounterd " +
                            "while accesing attribute = '%s' and bean class='%s'",
                                attribute, bean.getClass().getName());
            throw new RuntimeException(msg, e);
        }
    }


    /**
     * Converts a series of string values to their boolean equivalents
     * True values: true, t, yes, y, 1
     * False values: Everything else
     * @param value value to interpret
     * @return true or valse
     */
    public static boolean toBoolean(String value) {
        boolean retval = false;
        if (value != null && value.length() > 0) {
            retval = Boolean.valueOf(value).booleanValue();
            if (!retval &&
                (value.equalsIgnoreCase("t") ||
                        value.equalsIgnoreCase("true") ||
                        value.equalsIgnoreCase("yes") ||
                        value.equalsIgnoreCase("y") ||
                        value.equalsIgnoreCase("1"))) {
                    retval = true;
                }
        }
        return retval;
    }

    /**
     * Includes arbitrary _local_ url as content
     * @param ctx caller's page context
     * @param url local url
     * @throws JspException if something goes wrong
     *
     * Note: Local means Urls in the same application
     */
    public static void includeContent(PageContext ctx, String url) throws JspException {
        HttpServletRequest request = (HttpServletRequest) ctx.getRequest();
        HttpServletResponse response = (HttpServletResponse) ctx.getResponse();
        RequestDispatcher rd =
            request.getSession(true).getServletContext().getRequestDispatcher(url);
        if (rd == null) {
            ListTagUtil.write(ctx, "<!-- " + url + " not found -->");
        }
        else {
            try {
                BufferedResponseWrapper wrapper = new BufferedResponseWrapper(response);
                rd.include(request, wrapper);
                wrapper.flush();
                ListTagUtil.write(ctx, wrapper.getBufferedOutput());
            }
            catch (Exception e) {
                throw new JspException(e);
            }
        }
    }

    /**
     * Parses a list of style classes into a string array
     * @param styles list of style classes separated by "|"
     * @return array of sytles
     */
    public static String[] parseStyles(String styles) {
        List tmp = new LinkedList();
        StringTokenizer strtok = new StringTokenizer(styles, "|");
        while (strtok.hasMoreTokens()) {
            tmp.add(strtok.nextToken().trim());
        }
        String[] retval = null;
        if (tmp.size() == 0) {
            retval = new String[0];
        }
        else {
            retval = new String[tmp.size()];
            tmp.toArray(retval);
        }
        return retval;
    }

    /**
     * Renders the pagingation links for a given list.
     * @param pageContext caller's page context
     * @param linkNames name of links to use, in render order
     * @param links map of string arrays key on link name
     * @throws JspException if something bad happens writing to the page
     */
    public static void renderPaginationLinks(PageContext pageContext,
            String[] linkNames, Map links) throws JspException {
        if (links.size() == 0) {
            return;
        }
        for (int x = 0; x < linkNames.length; x++) {
            String[] linkData = (String[]) links.get(linkNames[x]);
            if (linkData[1] != null) {
                ListTagUtil.write(pageContext, "<input align=\"top\" type=\"image\" ");
                ListTagUtil.write(pageContext, "src=\"");
                ListTagUtil.write(pageContext, linkData[0]);
                ListTagUtil.write(pageContext, "\" name=\"");
                ListTagUtil.write(pageContext, linkData[1]);
                ListTagUtil.write(pageContext, "\" value=\"");
                ListTagUtil.write(pageContext, linkData[2]);
                ListTagUtil.write(pageContext, "\" alt=\"");
                ListTagUtil.write(pageContext, linkData[3]);
                ListTagUtil.write(pageContext, "\" />");

                ListTagUtil.write(pageContext, "<input type=\"hidden\" name=\"");
                ListTagUtil.write(pageContext, linkData[1]);
                ListTagUtil.write(pageContext, "\" value=\"");
                ListTagUtil.write(pageContext, linkData[2]);
                ListTagUtil.write(pageContext, "\" />");
            }
            else {
                ListTagUtil.write(pageContext, "<img align=\"top\" src=\"");
                ListTagUtil.write(pageContext, linkData[0]);
                ListTagUtil.write(pageContext, "\">");
                if (linkData[1] != null) {
                    ListTagUtil.write(pageContext, "</a>");
                }
            }
        }
    }

    /**
     * Returns the name of the attribute that holds the  parent is an element
     * value (used by list tag)
     * @param listName the list name
     * @return the label of the parent is an element attribute
     */
    public static String makeParentIsAnElementLabel(String listName) {
        return "list_" + listName + "_parent_is_an_element";
    }

    /**
     * Renders the filter UI
     * @param pageContext caller's page context
     * @param filter ListFilter instance
     * @param uniqueName name of the list
     * @param width width of the list
     * @param columnCount list's column count
     * @param searchParent true if list tag allows searching of parent
     * @param searchChild true if the list tag allows searching of child
     * @throws JspException if something bad happens writing to the page
     */
    public static void renderFilterUI(PageContext pageContext, ListFilter filter,
            String uniqueName, String width, int columnCount,
             boolean searchParent, boolean searchChild) throws JspException {
        LocalizationService ls = LocalizationService.getInstance();
        HttpServletRequest request = (HttpServletRequest) pageContext
                .getRequest();
        String filterByKey = makeFilterByLabel(uniqueName);
        String filterBy = request.getParameter(filterByKey);
        String filterValueKey = makeFilterValueByLabel(uniqueName);
        String filterName = makeFilterNameByLabel(uniqueName);
        String filterValue =  ListTagHelper.getFilterValue(pageContext.getRequest(),
                uniqueName);


        //We set this so we know next time around what the old filter value was
        ListTagUtil.write(pageContext, String.format(HIDDEN_TEXT,
                        makeOldFilterValueByLabel(uniqueName), filterValue));


        ListTagUtil.write(pageContext, "<td");
        ListTagUtil.write(pageContext, " align=\"left\">");
        List fields = filter.getFieldNames();
        if (fields == null || fields.size() == 0) {
            throw new JspException(
                    "ListFilter.getFieldNames() returned no field names");
        }
        else if (fields.size() == 1) {
            String label = ls.getMessage("message.filterby",
                                            fields.get(0).toString());
            ListTagUtil.write(pageContext, label);
            ListTagUtil.write(pageContext, "<input type=\"hidden\" name=\"");
            ListTagUtil.write(pageContext, filterByKey);
            ListTagUtil.write(pageContext, "\" value=\"");
            ListTagUtil.write(pageContext, fields.get(0).toString());
            ListTagUtil.write(pageContext, "\" />");
        }
        else {
            String label = ls.getMessage("message.filterby.multiple");
            ListTagUtil.write(pageContext, label);
            ListTagUtil.write(pageContext, "<select name=\"");
            ListTagUtil.write(pageContext, filterByKey);
            ListTagUtil.write(pageContext, "\">");
            for (Iterator iter = fields.iterator(); iter.hasNext();) {
                String field = (String) iter.next();
                ListTagUtil.write(pageContext, "<option value=\"");
                ListTagUtil.write(pageContext, field);
                ListTagUtil.write(pageContext, "\" ");
                if (field.equals(filterBy)) {
                    ListTagUtil.write(pageContext, "selected");
                }
                ListTagUtil.write(pageContext, ">");
                ListTagUtil.write(pageContext, field);
                ListTagUtil.write(pageContext, "</option>");
            }
            ListTagUtil.write(pageContext, "</select>");
        }
        ListTagUtil.write(pageContext, "&nbsp;&nbsp;");
        ListTagUtil.write(pageContext, "<input type=\"text\" name=\"");
        ListTagUtil.write(pageContext, filterValueKey);
        ListTagUtil.write(pageContext, "\" length=\"40\" size=\"10\" value=\"");
        if (filterValue != null) {
            ListTagUtil.write(pageContext, filterValue);
        }
        ListTagUtil.write(pageContext, "\" />");

        ListTagUtil.write(pageContext, IE_MAGIC_SNIPPET);
        ListTagUtil.write(pageContext,
                "&nbsp;&nbsp;&nbsp;<input type=\"submit\"" +  "name=\""  +
                filterName + "\"" +  "value=\"" +
                ls.getMessage(RequestContext.FILTER_KEY) + "\" />");
        ListTagUtil.write(pageContext, "</td>");
    }

    private static String makePageLink(HttpServletRequest request,
            String listName, String page) {
        String url = makeNonPagedLink(request, listName);
        if (url.indexOf("?") == -1) {
            url += "?";
        }
        else {
            url += "&";
        }
        url += "list_" + listName;
        url += "_page=" + page;
        return url;

    }

    private static String makeNonPagedLink(HttpServletRequest request, String listName) {
        String url = (String) request.getAttribute("parentUrl");
        String queryString = request.getQueryString();
        if (queryString != null && queryString.length() > 0) {
            url += "?";
            for (StringTokenizer strtok = new StringTokenizer(queryString, "&");
                    strtok.hasMoreTokens();) {
                String token = strtok.nextToken();
                if (token.indexOf(listName) > -1 && token.indexOf("_page=") > -1) {
                    continue;
                }
                else {
                    if (url.endsWith("?")) {
                        url += token;
                    }
                    else {
                        url = url + "&" + token;
                    }
                }
            }
        }
        return url;
    }

}
