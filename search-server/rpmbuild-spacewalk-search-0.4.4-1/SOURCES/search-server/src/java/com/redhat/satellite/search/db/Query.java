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

package com.redhat.satellite.search.db;

import com.ibatis.sqlmap.client.SqlMapSession;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Named Select query
 * @param <T> type returned by query
 * 
 * @version $Rev$
 */
public class Query<T> {

    private SqlMapSession session;
    private String queryName;

    Query(SqlMapSession sessionIn, String queryNameIn) {
        session = sessionIn;
        queryName = queryNameIn;
    }

    /**
     * Close query and associated resources
     * @throws SQLException something bad happened
     */
    public void close() throws SQLException {
        try {
            try {
                session.commitTransaction();
            }
            catch (SQLException e) {
                session.endTransaction();
            }
        }
        finally {
            session.close();
        }
    }

    /**
     * Load list of objects from query
     * @param param query param
     * @return list of T
     * @throws SQLException something bad happened
     */
    @SuppressWarnings("unchecked")
    public List<T> loadList(Object param) throws SQLException {
        List r = session.queryForList(queryName, param);
        List<Object> results = (List<Object>)r;
        List<T> retval = new ArrayList<T>(results.size());
        for (Object item : results) {
            retval.add((T)item);
        }
        return retval;
    }

    /**
     * Load single object from query
     * @param param query apram
     * @return T
     * @throws SQLException something bad happened
     */
    @SuppressWarnings("unchecked")
    public T load(Object param) throws SQLException {
        return (T)session.queryForObject(queryName, param);
    }
    
    /**
     * Load single object from query
     * @return T
     * @throws SQLException something bad happened
     */
    @SuppressWarnings("unchecked")
    public T load() throws SQLException {
        return (T)session.queryForObject(queryName);
    }
}
