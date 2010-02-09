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
package com.redhat.rhn.frontend.taglibs.helpers;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.frontend.struts.RequestContext;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * Makes it easier to work with the list view code
 * 
 * @version $Rev $
 */
public class ListViewHelper {
    
    private static final String DEFAULT_DISPLAY_NAME = "pageList";
       
    private RequestContext ctx = null;
    private DataResult result = null;
    private String filterByField = null;
    private DataResult filteredResult = null;
    private boolean isFiltering = false;
    private int pageSize = -1;
    
    /**
     * Initializes the helper. A new helper instance should be created for each
     * request. Caching helpers is strongly discouraged.
     * @param requestContext current request
     * @param filterField name of the DTO/Map field which will be filtered
     * For example, if the DTO has a <code>getLabel</code> method, then the 
     * field name would be label.
     */
    public ListViewHelper(RequestContext requestContext, String filterField) {
        this.ctx = requestContext;
        this.filterByField = filterField;
        // Default to the User's page size.  Can be overriden by calling setPageSize()
        this.pageSize = requestContext.getLoggedInUser().getPageSize();
    }
    
    /**
     * Sets the DataResult reference
     * @param data data to drive the list view
     */
    public void setData(DataResult data) {
        this.result = data;
    }
    
    /**
     * Indicate if the data result can be filtered
     * @param flag on/off toggle
     */
    public void isFiltering(boolean flag) {
        this.isFiltering = flag;
    }
    
    /**
     * Gets the filter parameter specified by the user
     * @return the value of the request parameter filter_string
     */
    public String getFilterParam() {
        String retval = this.ctx.getParam("filter_string", false);
        if (retval != null && retval.length() == 0) {
            retval = null;
        }
        else if (retval != null) {
            retval = retval.trim();
        }
        return retval;
    }
    
    /**
     * Gets the filter parameter specified by the user on the immediately prior request
     * @return the value of the request parameter filter_string
     */
    public String getPreviousFilterParam() {
        String retval = this.ctx.getParam("prev_filter_value", false);
        if (retval != null && retval.length() == 0) {
            retval = null;
        }
        else if (retval != null) {
            retval = retval.trim();
        }
        return retval;                
    }
    
    /**
     * Sets up the environment for list view processing
     * This should be called immediately before rendering the page containing
     * the list view
     */
    public void prepare() {
        prepare(DEFAULT_DISPLAY_NAME);
    }
    
    /**
     * Sets up the environment for list view processing
     * This should be called immediately before rendering the page containing
     * the list view
     * @param displayName the name to store the list view's data under
     */
    public void prepare(String displayName) {
        if (this.result == null) {
            return;
        }
        this.result.setFilter(this.isFiltering);
        if (getFilterParam() != null) {
            filterData();
        }
        processPagination();
        if (this.filteredResult != null) {
            this.ctx.getRequest().setAttribute(displayName, this.filteredResult);
        }
        else {
            this.ctx.getRequest().setAttribute(displayName, this.result);
        }
    }

    /**
     * Set number of items per page
     * @param size number of items on page
     */
    public void setItemsPerPage(int size) {
        this.pageSize = size;
    }
    
    /**
     * Number of items on page
     * @return items on page
     */
            
    public int getItemsPerPage() {
        return this.pageSize;
    }
    
    private void processPagination() {
        String rawStart = ctx.processPagination();
        if (hasFilterCriteriaReset()) {
            rawStart = "1";
        }
        else if (rawStart == null) {
            rawStart = "1";
        }
        int start = Integer.parseInt(rawStart);
        int end = start + this.pageSize;
        if (this.filteredResult != null) {
            DataResult tmp = this.filteredResult.slice(start - 1, end - 1);
            tmp.setFilterData(getFilterParam());
            tmp.setFilter(true);
            this.filteredResult = tmp;
            this.filteredResult.setStart(start);
            this.filteredResult.setEnd((start + this.filteredResult.size()) - 1);
        }
        else {
            this.result = this.result.slice(start - 1, end - 1);
            this.result.setStart(start);
            this.result.setEnd((start + this.result.size()) - 1);
        }
    }
    
    private void filterData() {
        if (result.size() == 0 || getFilterParam() == null) {
            return;
        }
        List filteredData = new LinkedList();
        Object datum = result.get(0);
        if (datum instanceof Map) {
            filterMaps(filteredData);
        }
        else {
            filterDtos(filteredData);
        }
        this.filteredResult = new DataResult(filteredData);
        this.filteredResult.setTotalSize(this.filteredResult.size());
        this.filteredResult.setStart(1);
        this.filteredResult.setFilter(true);
        this.filteredResult.setFilterData(getFilterParam());
    }
    
    private void filterMaps(List accum) {
        String filterValue = getFilterParam();
        for (Iterator iter = this.result.iterator(); iter.hasNext();) {
            Map row = (Map) iter.next();
            String value = (String) row.get(this.filterByField);
            if (value != null && value.contains(filterValue)) {
                accum.add(row);
            }
        }
    }
    
    private void filterDtos(List accum) {
        String filterValue = getFilterParam();
        Object dto = this.result.get(0);
        Method method = locateFilterMethod(dto);
        if (method == null) {
            return;
        }
        for (Iterator iter = this.result.iterator(); iter.hasNext();) {
            Object o = iter.next();
            try {
                String value = (String) method.invoke(o, (Object[])null);
                if (value.contains(filterValue)) {
                    accum.add(o);
                }
            }
            catch (IllegalAccessException e) {
                e.printStackTrace();
                continue;
            }
            catch (IllegalArgumentException e) {
                e.printStackTrace();
                continue;
            }
            catch (InvocationTargetException e) {
                e.printStackTrace();
                continue;
            }
        }
    }
    
    private Method locateFilterMethod(Object dto) {
        Method retval = null;
        String methodName = this.filterByField;
        methodName = "get" + methodName.substring(0, 1).toUpperCase() +
            methodName.substring(1);
        Method[] methods = dto.getClass().getMethods();
        for (int x = 0; x < methods.length; x++) {
            if (methods[x].getName().equals(methodName)) {
                retval = methods[x];
                break;
            }
        }
        return retval;
    }
    
    private boolean hasFilterCriteriaReset() {
        boolean retval = false;
        String prevFilter = getPreviousFilterParam();
        String currentFilter = getFilterParam();
        if ((prevFilter != null && currentFilter != null) && 
                !prevFilter.equals(currentFilter)) {
            retval = true;
            
        }
        else if ((prevFilter == null && currentFilter != null) || prevFilter != null && 
                currentFilter == null) {
            retval = true;
        }
        return retval;
    }
}
