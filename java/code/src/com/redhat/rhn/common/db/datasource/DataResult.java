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
package com.redhat.rhn.common.db.datasource;

import com.redhat.rhn.common.util.CharacterMap;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * The results of operations on the DataSource layer.
 * @param <T> the type of the objects to be used in this list.
 * @version $Rev$
 */
public class DataResult<T> extends ArrayList<T> implements List<T> {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 1484060225822305422L;
    // We need access to methods that only SelectModes have, so we force
    // SelectMode here, but we return Mode to the user when asked for it.
    private SelectMode mode;
    private int totalSize;
    private int start;
    private int end;
    private CharacterMap index;
    private String filterData;
    private boolean filter;
    private Map elabParams;

    /**
     * Create a new DataResult object
     * @param dr The Mode that created this DataResult
     */
    protected DataResult(DataResult dr) {
        super(dr);
        mode = dr.getMode();
        start = dr.getStart();
        end = dr.getEnd();
        totalSize = dr.getTotalSize();
        index = dr.getIndex();
        filterData = dr.getFilterData();
        filter = dr.hasFilter();
        elabParams = dr.getElaborationParams();
    }

    /**
     * Create a new DataResult object
     * @param m The Mode that created this DataResult
     */
    protected DataResult(Mode m) {
        super();
        mode = (SelectMode)m;
    }

    /**
     * Create a new DataResult object
     * @param l The list to add
     * @param m The Mode that created this DataResult
     */
    protected DataResult(Collection l, Mode m) {
        super(l);
        mode = (SelectMode)m;
    }

    /**
     * Create a DataResult with a simple Collection
     * and null the Mode.  Useful for creating DataResults of
     * short lists Hibernate Objects
     * @param l Collection of Objects you want in the Result
     */
    public DataResult(Collection l) {
        this(l, null);
        this.setTotalSize(l.size());
        start = 1;
        end = l.size();
    }

    /**
     * Get the mode associated with this DataResult.
     * @return Mode used by this DataResult.
     */
    public SelectMode getMode() {
        return mode;
    }

    /** {@inheritDoc} */
    public DataResult<T> subList(int fromIndex, int toIndex) {
        int last = toIndex;

        //check bounds
        if (last > size()) {
            last = size();
        }
        if (fromIndex >= last) {
            //<last> - <last> of <last>
            fromIndex = last - 1;
        }
        if (fromIndex == -1) {
            return new DataResult(mode);
        }

        List temp = super.subList(fromIndex, last);
        DataResult dr = new DataResult(temp, mode);
        dr.start = fromIndex + 1;
        dr.end = toIndex;
        dr.totalSize = this.getTotalSize();
        dr.index = this.getIndex();
        dr.filterData = this.getFilterData();
        dr.filter = this.hasFilter();
        return dr;
    }

    /**
     * Performs the function as <code>subList()</code> except it
     * returns a DataResult object. This should be refactored at some point
     * @param fromIndex start
     * @param toIndex end
     * @return new DataResult containing the requested "sublist"
     */
    public DataResult<T> slice(int fromIndex, int toIndex) {
        return subList(fromIndex, toIndex);
    }

    /**
     * Elaborate the current DataResult with more values, using ID as the
     * key.  This will execute all elaborators.
     * @param values The values to bind to the BindParameters
     */
    public void elaborate(Map values) {
        elabParams = values;
        if (mode != null) {
            mode.elaborate(this, values);
        }
    }
    /**
     * Elaborate the current DataResult with more values, using ID as the
     * key.  This will execute all elaborators.
     */
    public void elaborate() {
        if (mode != null) {
            if (getElaborationParams() == null) {
                mode.elaborate(this, Collections.EMPTY_MAP);
            }
            else {
                mode.elaborate(this, getElaborationParams());
            }

        }
    }
    /**
     *
     * @return An elaborator object that could be used for elaboration later in
     *                          cycle.
     */
    public Elaborator getElaborator() {
       return new ModeElaborator(mode, elabParams);
    }

    /**
     * Return the parameters that were passed into the last call to elaborate()
     * @return Map of elaboration values
     */
    public Map getElaborationParams() {
        return elabParams;
    }

    /**
     * Set the parameters that will be used to elaborate the query
     * Note that we make this public because we can't guarantee that
     * elaborate(Map) will be called from the outside in every case where
     * we need them.
     * @param values name/value pairs used to elaborate the query
     *
     */
    public void setElaborationParams(Map values) {
        elabParams = values;
    }

    /**
     * Get the total number of entries in this list
     * @return Returns the totalSize.
     */
    public int getTotalSize() {
        return totalSize;
    }

    /**
     * Set the total number of entries in this list
     * @param ts The totalSize to set.
     */
    public void setTotalSize(int ts) {
        this.totalSize = ts;
    }

    /**
     * Get the index of the first element in the list
     * @return the index of the first element of the list
     */
    public int getStart() {
        return start;
    }

    /**
     * Provide a start value.
     * @param startIn we want to set.
     */
    public void setStart(int startIn) {
        this.start = startIn;
    }

    /**
     * Get the index of the list element in the list
     * @return the index of the last element of the list
     */
    public int getEnd() {
        return end;
    }

    /**
     * Set the End value.
     * @param endIn that we want to set.
     */
    public void setEnd(int endIn) {
        this.end = endIn;
    }

    /**
     * Get the index
     * @return A CharacterMap containing the index for the list
     */
    public CharacterMap getIndex() {
        if (index == null) {
            this.index = new CharacterMap();
        }
        return index;
    }

    /**
     * Set the index
     * @param i The new value for index
     */
    public void setIndex(CharacterMap i) {
        this.index = i;
    }

    /**
     * Has this data been filtered
     * @return True if the data is be filtered
     */
    public boolean hasFilter() {
        return filter;
    }

    /**
     * Set if we this data has been filtered
     * @param isFilter Has this been filtered
     */
    public void setFilter(boolean isFilter) {
        filter = isFilter;
    }

    /**
     * Get the data used to filter this list.
     * @return The data used to filter this list
     */
    public String getFilterData() {
        if (filterData == null) {
            return "";
        }
        return filterData;
    }

    /**
     * Set the data used to filter this list.
     * @param fData The data used to filter this list.
     */
    public void setFilterData(String fData) {
        filterData = fData;
    }

    /** {@inheritDoc} */
    public String toString() {
        return "{Start: " + start + " End: " + end + " Total: " + totalSize +
               super.toString() + "}";
    }


}
