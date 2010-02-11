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

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * A cached set of query/elaborator strings and the parameterMap hash maps.
 *
 * @version $Rev$
 */
public class SelectMode extends BaseMode {

    private String clazz;
    private List elaborators;
    private int maxRows;

    // We could (and probably should) cache the ResultSet metadata here as
    // well.  There is no reason that the first call to each statement
    // couldn't do the work to determine what is returned.
    
    /** Constructs a new SelectMode */
    public SelectMode() {
        elaborators = new ArrayList();
    }

    /**
     * Copy constructor
     * @param modeIn The mode to copy into new SelectMode object
     */
    public SelectMode(SelectMode modeIn) {
        if (modeIn != null) {
            this.clazz = modeIn.getClassString();
            this.elaborators = new ArrayList(modeIn.getElaborators());
            setName(modeIn.getName());
            setQuery(new CachedStatement(modeIn.getQuery()));
        }
    }
    
    /**
     * Set the class for this mode.
     * @param c the class to set
     */
    void setClassString(String c) {
        clazz = c;
    }

    /**
     * get the class
     * @return the class
     */
    public String getClassString() {
        return clazz;
    }

    /**
     * Adds an elaborator query.
     * @param q Elaborator query to execute.
     */
    public void addElaborator(CachedStatement q) {
        elaborators.add(q);
    }

    /**
     * Returns the list of elaborator queries.
     * @return List of elaborator queries.
     */
    public List getElaborators() {
        return elaborators;
    }

    /**
     * Executes the query using the given paramters and sort options.
     * @param parameters Query paramters.
     * @param sortColumn column used for sorting.
     * @param order Sorting order ASC or DESC
     * @return DataResult containing results from query.
     */
    public DataResult execute(Map parameters, String sortColumn, String order) {
        return getQuery().execute(parameters, sortColumn, order, this);
    }

    /**
     * Executes the query using the given parameters.
     * @param parameters Query parameters.
     * @return DataResult containing results from query.
     */
    public DataResult execute(Map parameters) {
        return getQuery().execute(parameters, this);
    }
    
    /**
     * Executes the query with an IN clause.
     * @param parameters Query parameters.
     * @return DataResult containing results from query.
     */
    public DataResult execute(List parameters) {
        return getQuery().execute(parameters, this);
    }
    
    /**
     * Executes the query with no parameters.
     * @return DataResult containing results from query.
     */
    public DataResult execute() {
        return getQuery().execute((Map) null, this);
    }
    
    /**
     * Executes the query with the given parameters an an IN clause.
     * @param parameters named parameters for the Query.
     * @param inClause values to be included in the IN clause.
     * @return DataResult containing results from query.
     */
    public DataResult execute(Map parameters, List inClause) {
        return getQuery().execute(parameters, inClause, this);
    }

    /**
     * Elaborates a list by calling the elaboration queries with the
     * given parameters.
     * @param resultList The resultList that has items from the driving
     *                   query results.
     * @param parameters named query parameters for elaborators.
     */
    public void elaborate(List resultList, Map parameters) {
        // find the requested elaborator.
        Iterator i = elaborators.iterator();
        CachedStatement cs = null;
        while (i.hasNext()) {
            cs = (CachedStatement)i.next();

            Collection elaborated = cs.executeElaborator(resultList, this,
                                                         parameters);
            resultList.clear();
            resultList.addAll(elaborated);
        }
    }

    /** {@inheritDoc} */
    public String toString() {
        String str = super.toString();
        return str + 
               "  # of elaborators: " + elaborators.size() + " ]";
    }
    
    /**
     * The maximum number of rows to be returned by the query. Zero (0)
     * means unlimited.
     * @param max maximum number of rows to be returned, zero (0) is unlimited.
     */
    public void setMaxRows(int max) {
        if (max < 0) {
            throw new IllegalArgumentException("max must be >= 0");
        }
        maxRows = max;
    }
    
    /**
     * Returns maximum number of rows to be returned by this query.
     * @return maximum number of rows to be returned by this query.
     */
    public int getMaxRows() {
        return maxRows;
    }
}

