/**
 * Copyright (c) 2009--2016 Red Hat, Inc.
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

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;

/**
 * A cached set of query/elaborator strings and the parameterMap hash maps.
 *
 * @version $Rev$
 */
public class SelectMode extends BaseMode implements Serializable {

    private String clazz;
    private List<CachedStatement> elaborators = new ArrayList<CachedStatement>();
    private int maxRows;

    // increase this number on any data change
    private static final long serialVersionUID = 1L;

    /**
     * Only used by DataListTest
     */
    protected SelectMode() { }

    /*package*/ SelectMode(ParsedMode parsedMode) {
        super(parsedMode);
        if (parsedMode != null) {
            this.clazz = parsedMode.getClassname();
            for (ParsedQuery parsedQuery : parsedMode.getElaborators()) {
                elaborators.add(new CachedStatement(parsedQuery));
            }
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
    public List<CachedStatement> getElaborators() {
        return elaborators;
    }

    /**
     * Executes the query using the given parameters.
     * @param parameters Query parameters.
     * @return DataResult containing results from query.
     */
    public DataResult execute(Map<String, ?> parameters) {
        return getQuery().execute(parameters, this);
    }

    /**
     * Executes the query with an IN clause.
     * @param inClause values to be included in the IN clause.
     * @return DataResult containing results from query.
     */
    public DataResult execute(List<?> inClause) {
        return getQuery().execute(inClause, this);
    }

    /**
     * Executes the query with no parameters.
     * @return DataResult containing results from query.
     */
    public DataResult execute() {
        return getQuery().execute((Map<String, ?>) null, this);
    }

    /**
     * Executes the query with the given parameters an an IN clause.
     * @param parameters named parameters for the Query.
     * @param inClause values to be included in the IN clause.
     * @return DataResult containing results from query.
     */
    public DataResult execute(Map<String, ?> parameters, List<?> inClause) {
        return getQuery().execute(parameters, inClause, this);
    }

    /**
     * Elaborates a list by calling the elaboration queries with the given
     * parameters.
     * @param resultList The resultList that has items from the driving query
     * results.
     * @param parameters named query parameters for elaborators.
     */
    public void elaborate(List resultList, Map<String, ?> parameters) {
        // find the requested elaborator.
        for (CachedStatement cs : elaborators) {
            Collection elaborated = cs.executeElaborator(resultList, this, parameters);
            resultList.clear();
            resultList.addAll(elaborated);
        }
    }

    /** {@inheritDoc} */
    @Override
    public String toString() {
        String str = super.toString();
        return str + "  # of elaborators: " + elaborators.size() + " ]";
    }

    /**
     * The maximum number of rows to be returned by the query. Zero (0) means
     * unlimited.
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
