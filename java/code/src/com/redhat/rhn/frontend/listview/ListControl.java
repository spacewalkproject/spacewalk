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
package com.redhat.rhn.frontend.listview;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.CharacterMap;
import com.redhat.rhn.common.util.MethodUtil;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.frontend.filter.Matcher;
import com.redhat.rhn.frontend.filter.ResultsFilter;

import java.util.Iterator;

/**
 * ListControl
 * ListControl is the basic method of control for a list of dataresults to be
 * shown with the ListDisplayTag. It provides filtering and indexing mechanisms
 * for showing data.
 * @version $Rev$
 */
public class ListControl {
    private boolean indexData;
    private String filterColumn;
    private String filterData;
    private boolean filter;
    private ResultsFilter customFilter;
    
    /**
     * Determine if this list should have an indexData
     * @return True if an indexData is desired
     */
    public boolean hasIndex() {
        return indexData;
    }
    
    /**
     * Set if this list should have an indexData
     * @param abar True if an indexData is desired
     */
    public void setIndexData(boolean abar) {
        this.indexData = abar;
    }
    
    /** Determine if this list should have a filter box
     * @return True if filter box is desired
     */
    public boolean hasFilter() {
        return filter;
    }
    
    /** Set if this list should have a filter box
     * @param filterIn True if filtering is desired
     */
    public void setFilter(boolean filterIn) {
        this.filter = filterIn;
    }
    
    /**
     * Get the column on which to filter
     * @return Returns the filterColumn.
     */
    public String getFilterColumn() {
        return filterColumn;
    }
    
    /**
     * Set the column on which to filter
     * @param fColumn The column on which to filter.
     */
    public void setFilterColumn(String fColumn) {
        this.filterColumn = fColumn;
    }
    
    /**
     * Get the data to filter for
     * @return Returns the filterData.
     */
    public String getFilterData() {
        return filterData;
    }
    
    /**
     * set the data to filter for
     * @param fData The to filter for.
     */
    public void setFilterData(String fData) {
        this.filterData = fData;
    }
    
    /** 
     * set the ListFilter object to use in filtering the data results
     * @param filterIn filter to use
     */
    public void setCustomFilter(ResultsFilter filterIn) {
        customFilter = filterIn;
    }
    
    /**
     * Create index on the DataResult dr
     * @param dr DataResult to create index on
     * @return CharacterMap containing index
     */
    public CharacterMap createIndex(DataResult dr) {
        // The crappy thing is that we  have to
        // iterate over the data in its entirety to
        // generate the set of actual characters that
        // exist in the alpha column
        CharacterMap alphaSet = new CharacterMap();
        Iterator di = dr.iterator();
        int i = 0;
        while (di.hasNext()) {
            Object inputRow = di.next();
            String value = (String)MethodUtil.callMethod(inputRow, 
                                                StringUtil.beanify("get " + filterColumn),
                                                new Object[0]);
            /* Filter the data if necessary
            if (filterValue != null && value != null) {
                if (value.indexOf(filterValue) < 0) {
                    di.remove();
                }
            }*/
            // Make sure that the alpha inputs are converted
            // to uppercase
            char val = value.charAt(0);
            val = Character.toUpperCase(val);
            if (!alphaSet.containsKey(val)) {
                // add the character to the set
                alphaSet.put(val, i + 1);
            }
            i++;
        }
        return alphaSet;
    }

    /**
     * Restrict the data that is in the list so that it matches the requested data.
     * Uses customFilter for filtering if a ListFilter was provided
     * @param dr DataResult to filter
     */
    public void filterData(DataResult dr) {
        Iterator di;
        
        if (customFilter == null) {
           Matcher matcher = Matcher.DEFAULT_MATCHER;
           di = dr.iterator();
            while (di.hasNext()) {
                if (!matcher.include(di.next(), filterData, filterColumn)) {
                    di.remove();
                }
            }  
        }
        else {
            customFilter.filterData(dr, filterData, filterColumn);
        }

        
        dr.setFilter(filter);
        dr.setFilterData(filterData);
    }
}
