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
import com.redhat.rhn.common.util.DynamicComparator;
import com.redhat.rhn.common.util.MethodUtil;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.frontend.html.HtmlTag;
import com.redhat.rhn.frontend.struts.RequestContext;

import org.apache.commons.lang.StringUtils;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;

/**
 * Provides a bunch of helper methods to make working with lists easier from a
 * custom tag POV.
 *
 * @version $Rev $
 */
public class DataSetManipulator {
    private static final String[] LINK_PREFIXES = {"_first", "_prev", "_next", "_last"};

    private int pageSize;
    private List dataset;
    private ListFilter filter;
    private String filterBy;
    private String filterValue;
    private int totalDataSetSize;
    private HttpServletRequest request;
    private String uniqueName;
    private int pageNumber = -1;
    private String alphaCol;
    private int alphaPosition = -1;
    private boolean ascending = true;
    private int unfilteredDataSize;
    private boolean parentIsAnElement;

    private boolean searchParent;
    private boolean searchChild;

    private String defaultSortAttribute;
    private static final String IMG_FIRST = "/img/list-allbackward.gif";
    private static final String IMG_FIRST_UNFOCUSED =
                                        "/img/list-allbackward-unfocused.gif";

    private static final String IMG_PREV = "/img/list-backward.gif";
    private static final String IMG_PREV_UNFOCUSED =
                                           "/img/list-backward-unfocused.gif";

    private static final String IMG_NEXT = "/img/list-forward.gif";
    private static final String IMG_NEXT_UNFOCUSED =
                                           "/img/list-forward-unfocused.gif";


    private static final String IMG_LAST = "/img/list-allforward.gif";
    private static final String IMG_LAST_UNFOCUSED =
                                    "/img/list-allforward-unfocused.gif";


    /**
     * Constructor
     * @param pageSizeIn page size of the list
     * @param datasetIn dataset to be displayed
     * @param requestIn HttpServletRequest of the caller
     * @param listNameIn name of the list
     * @param parentIsElement true of the parent value
     *          in the list should be considered as an element
     *          this is useful for tree like data
     * @param doSearchParent true if we want to search the parent value
     *          in the list when filtering.
     * @param doSearchChild true if we want to search the child value
     *          in the list when filtering.
     */
    public DataSetManipulator(int pageSizeIn, List datasetIn,
            HttpServletRequest requestIn, String listNameIn,
            boolean parentIsElement, boolean doSearchParent,
            boolean doSearchChild) {
        pageSize = pageSizeIn;
        dataset = datasetIn;
        request = requestIn;
        uniqueName = listNameIn;
        totalDataSetSize = dataset.size();
        unfilteredDataSize = dataset.size();
        parentIsAnElement = parentIsElement;
        searchParent = doSearchParent;
        searchChild = doSearchChild;
    }

    private List expand(List data) {
        return ListFilterHelper.filterChildren(data,
                filter, filterBy, filterValue, searchParent, searchChild);
    }
    /**
     * Get the total (non-filtered, non-paginated) dataset size
     * @return total size
     */
    public int getTotalDataSetSize() {
        return totalDataSetSize;
    }

    /**
     * Find a page-worth of data
     * @return list representing one page of data
     */
    public List getPage() {
        List retval = new LinkedList();
        if (pageSize > 0) {
            int startOffset = getCurrentPageNumber() * pageSize;
            if (startOffset > dataset.size()) {
                startOffset = dataset.size() - 1;
            }
            if (startOffset < 0) {
                startOffset = 0;
            }
            int endOffset = startOffset + pageSize;
            if (endOffset > dataset.size()) {
                endOffset = dataset.size();
            }
            retval = dataset.subList(startOffset, endOffset);
        }
        else {
            retval.addAll(dataset);
        }
        return expand(retval);
    }

    /**
     * Return everything in the list, not just enough for a single page
     * @return List representing all data available
     */
    public List getAllData() {
        List retval = new LinkedList();
        retval.addAll(dataset);
        return expand(retval);
    }

    /**
     * Returns the starting element index for a page (1 based)
     * @return int
     */
    private int getPageStartIndex() {
        //no data ==> no start index...
        if (getTotalDataSetSize() == 0) {
            return 0;
        }

        int startOffset = getCurrentPageNumber() * pageSize;

        if (startOffset < 0) {
            startOffset = 0;
        }
        List parentList = dataset.subList(0, startOffset);
        List data = expand(parentList);
        int ret = data.size() + 1;

        if (!parentIsAnElement) {
            ret = ret - parentList.size();
        }
        return ret;
    }

    /**
     * Returns the ending element index for a page (1 based)
     * @return int
     */
    private int getPageEndIndex() {
        int startOffset = getCurrentPageNumber() * pageSize;
        if (startOffset < 0) {
            startOffset = 0;
        }

        int endOffset = startOffset + pageSize;
        if (endOffset > dataset.size()) {
            endOffset = dataset.size();
        }
        List parentList = dataset.subList(0, endOffset);
        List data = expand(parentList);

        if (!parentIsAnElement) {
            return data.size() - parentList.size();
        }

        return data.size();
    }

    private int getExpandedDataSize() {
        if (!parentIsAnElement) {
            return expand(dataset).size() - dataset.size();
        }
        return expand(dataset).size();
    }

    /**
     * Returns the pagination message (1 - 2 of 3 for example)
     * @return the pagination message
     */
    public String getPaginationMessage() {
        LocalizationService ls = LocalizationService.getInstance();
        return ls.getMessage("message.range", getPageStartIndex(),
                    getPageEndIndex(), getExpandedDataSize());

    }


    /**
     * Determines the current page number based on URL params
     * @return current page number
     */
    private  int getCurrentPageNumber() {

        if (AlphaBarHelper.getInstance().isSelected(uniqueName, request)) {
            int pos = findAlphaPosition();
            pageNumber = pos / pageSize;
            return pageNumber;
        }



        if (pageNumber == -1) {
            String param = null;
            param = getPaginationParam(request, uniqueName);
            String value = null;
            if (param != null && request.getParameter(param) != null) {
                value = request.getParameter(param);
            }
            if (value == null) {
                value = "0";
            }
            else if (value.equalsIgnoreCase("first")) {
                value = "0";
            }
            else if (value.equalsIgnoreCase("last")) {
                if (totalDataSetSize == 0) {
                    value = "0";
                }
                else {
                    value = String.valueOf((totalDataSetSize - 1) / pageSize);
                }
            }
            try {
                pageNumber = Integer.parseInt(value);
            }
            catch (NumberFormatException e) {
                pageNumber = 0;
            }
        }

        return pageNumber;
    }

    /**
     * Binds information pertaining to pagination to the request
     */
    public void bindPaginationInfo() {
        request.setAttribute("pageNum", String.valueOf(getCurrentPageNumber()));
    }
    /**
     * Returns the pagination param (|<, <, >, >|) that was selected
     * returns null if no pagination action was selected.
     * @param request the http servlet request
     * @param uniqueName the unique name of list to check
     * @return the selected pagination param or null if none was selected.
     */
     static  String getPaginationParam(ServletRequest request, String uniqueName) {

        for (int x = 0; x < LINK_PREFIXES.length; x++) {
            String imgLink = "list_" + uniqueName + "_page" +
            LINK_PREFIXES[x] + ".x";

            if (request.getParameter(imgLink) != null) {
                return  "list_" + uniqueName + "_page" + LINK_PREFIXES[x];

            }
        }
        return null;
    }

    /**
     * Returns the next page number
     * @return next page number or -1 if none
     */
    public int getNextPageNumber() {
        int retval = -1;
        if (getCurrentPageNumber() == 0) {
            if (totalDataSetSize > pageSize) {
                retval = getCurrentPageNumber() + 1;
            }
        }
        else {
            if ((getCurrentPageNumber() * pageSize) + pageSize < (totalDataSetSize)) {
                retval = getCurrentPageNumber() + 1;
            }
        }
        return retval;
    }

    /**
     * Returns the previous page number
     * @return previous page number of -1 if none
     */
    public int getPrevPageNumber() {
        int retval = -1;
        if (getCurrentPageNumber() > 0) {
            if (((getCurrentPageNumber() * pageSize) - pageSize) > -1) {
                retval = getCurrentPageNumber() - 1;
            }
        }
        return retval;
    }

    /**
     * Is the current page the first page?
     * @return answer to that burning question
     */
    public boolean isFirstPage() {
        return getCurrentPageNumber() == 0;
    }

    /**
     * Is the current page the last page?
     * @return answer to that burning question
     */
    public boolean isLastPage() {
        int maxPage = (dataset.size() / pageSize) - 1;
        // Add a page for overflow, since the dataset is not
        // evenly divisible by the pagesize
        if (dataset.size() % pageSize > 0) {
            maxPage++;
        }
        return getCurrentPageNumber() == maxPage;
    }

    /**
     * Sorts the dataset in place
     */
    public void sort() {

        String sortKey = ListTagUtil.makeSortByLabel(uniqueName);
        String sortDirectionKey = ListTagUtil.makeSortDirLabel(uniqueName);
        String sortAttribute = request.getParameter(sortKey);
        String sortDir = request.getParameter(sortDirectionKey);
        if (AlphaBarHelper.getInstance().isSelected(uniqueName, request)) {
            Collections.sort(dataset, new DynamicComparator(alphaCol,
                    RequestContext.SORT_ASC));
        }
        else if (!StringUtils.isBlank(sortAttribute)) {
            Collections.sort(dataset, new DynamicComparator(sortAttribute,
                    sortDir));
        }
        else if (!StringUtils.isBlank(defaultSortAttribute)) {
            Collections.sort(dataset, new DynamicComparator(defaultSortAttribute,
                    ascending ? RequestContext.SORT_ASC : RequestContext.SORT_DESC));
        }
    }

    /**
     * Filters the dataset based on filter criteria
     * @param f ListFilter instance
     * @param context the page context to write to
     * @throws JspException if failure to write to pageContext
     */
    public void filter(ListFilter f, PageContext context) throws JspException {


        String filterByKey = ListTagUtil.makeFilterByLabel(uniqueName);
        filterBy = request.getParameter(filterByKey);
        filterValue = ListTagHelper.getFilterValue(request, uniqueName);


        if (f == null || filterBy == null || filterBy.length() == 0 ||
                filterValue == null || filterValue.length() == 0) {
            return;
        }
        else {
            filter = f;
            HtmlTag filterClass = new HtmlTag("input");
            filterClass.setAttribute("type", "hidden");
            filterClass.setAttribute("name", ListTagUtil.makeFilterClassLabel(uniqueName));
            filterClass.setAttribute("value", f.getClass().getCanonicalName());
            ListTagUtil.write(context, filterClass.render());

            dataset = ListFilterHelper.filter(dataset, f, filterBy, filterValue,
                                                        searchParent, searchChild);
            totalDataSetSize = dataset.size();
        }
    }

    /**
     * Builds a map of bog-standard pagination links complete with images
     * @return map (String, String[])
     */
    public Map getPaginationLinks() {
        Map links = new HashMap();
        if (pageSize > 0 && dataset.size() > 0 && getTotalDataSetSize() > pageSize) {
            String pageLinkName = "list_" + uniqueName + "_page";
            String[] data = new String[4];
            if (!isFirstPage()) {
                data[0] = IMG_FIRST;
                data[1] = pageLinkName + "_first";
                data[2] = "first";
                data[3] = "First Page";

            }
            else {
                data[0] = IMG_FIRST_UNFOCUSED;
                data[1] = null;
                data[2] = null;
                data[3] = null;
            }
            links.put("allBackward", data);
            data = new String[4];
            if (getPrevPageNumber() > -1) {
                data[0] = IMG_PREV;
                data[1] = pageLinkName + "_prev";
                data[2] = String.valueOf(getPrevPageNumber());
                data[3] = "Previous Page";
            }
            else {
                data[0] = IMG_PREV_UNFOCUSED;
                data[1] = null;
                data[2] = null;
                data[3] = null;
            }
            links.put("backward", data);
            data = new String[4];
            if (getNextPageNumber() > -1) {
                data[0] = IMG_NEXT;
                data[1] = pageLinkName + "_next";
                data[2] = String.valueOf(getNextPageNumber());
                data[3] = "Next Page";
            }
            else {
                data[0] = IMG_NEXT_UNFOCUSED;
                data[1] = null;
                data[2] = null;
                data[3] = null;
            }
            links.put("forward", data);
            data = new String[4];
            if (!isLastPage()) {
                data[0] = IMG_LAST;
                data[1] = pageLinkName + "_last";
                data[2] = "last";
                data[3] = "Last Page";
            }
            else {
                data[0] = IMG_LAST_UNFOCUSED;
            }
            links.put("allForward", data);
        }
        return links;

    }

    /**
     * Is the list empty?
     * @return boolean
     */
    public boolean isListEmpty() {
        return dataset == null || dataset.size() == 0;
    }

    /**
     *  Gets the set of characters that will be active on the alpha bar
     * @return the set of characters that are active
     */
    public Set<Character> getAlphaBarIndex() {
        Set<Character> chars = new HashSet<Character>();
        int i = 0;
        for (Object inputRow : dataset) {
            String value = (String)MethodUtil.callMethod(inputRow,
                                                StringUtil.beanify("get " + alphaCol),
                                                new Object[0]);
            if (!StringUtils.isBlank(value)) {
                // Make sure that the alpha inputs are converted
                // to uppercase
                char val = value.charAt(0);
                val = Character.toUpperCase(val);
                if (!chars.contains(val)) {
                    // add the character to the set
                    chars.add(val);
                }
            }
            i++;
        }
        return chars;
    }

    /**
     * setter for the column that will be sorted when the alpha bar is used
     * @param col the column to set
     */
    public void setAlphaColumn(String col) {
        alphaCol = col;
    }

    /**
     * Finds the first instance of an entry in DataSet that starts with the letter
     *          "alphaPosition"
     * @return int the position within the DataSet of that entry
     */
    public int findAlphaPosition() {
        AlphaBarHelper helper = AlphaBarHelper.getInstance();
        if (helper.isSelected(uniqueName, request)) {
            if (alphaPosition > -1) {
                return alphaPosition;
            }
            char alpha = Character.toUpperCase(helper.
                                getAlphaValue(uniqueName, request).charAt(0));


            int i = 0;
            for (Object inputRow : dataset) {
                String value = (String)MethodUtil.callMethod(inputRow,
                                                    StringUtil.beanify("get " + alphaCol),
                                                    new Object[0]);
                if (!StringUtils.isBlank(value)) {
                    char val = value.charAt(0);
                    val = Character.toUpperCase(val);
                    if (val == alpha) {
                        alphaPosition = i;
                        return i;
                    }
                }
                i++;
            }
        }
        return -1;
    }


    /**
     *
     * @return the defualt sort attribute
     */
    public String getDefaultSortAttribute() {
        return defaultSortAttribute;
    }
    /**
     *
     * @param sortAttr the default sort attribute
     */
    public void setDefaultSortAttribute(String sortAttr) {
        defaultSortAttribute = sortAttr;
    }

    /**
     *
     * @param asc the sort order
     */
    public void setDefaultAscending(boolean asc) {
        ascending = asc;
    }


    /**
     * @return Returns the unfilteredDataSize.
     */
    public int getUnfilteredDataSize() {
        return unfilteredDataSize;
    }
}
