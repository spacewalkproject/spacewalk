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

/**
 * Query for writing (insert, update, delete) to a database
 * 
 * @version $Rev$
 */
public class WriteQuery {
    
    private SqlMapSession session;
    private String queryName;

    WriteQuery(SqlMapSession sessionIn, String queryNameIn) {
        session = sessionIn;
        queryName = queryNameIn;
    }
    
    /**
     * Close query and all associated resources
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
     * Execute update query
     * @param param query param
     * @return number of rows updated
     * @throws SQLException something bad happened
     */
    public int update(Object param) throws SQLException {
        return session.update(queryName, param);
    }
    
    /**
     * Execute delete query
     * @param param query param
     * @return number of rows updated
     * @throws SQLException something bad happened
     */    
    public int delete(Object param) throws SQLException {
        return session.delete(queryName, param);
    }
    
    /**
     * Execute insert query
     * @param param query param
     * @throws SQLException something bad happened
     */    
    public void insert(Object param) throws SQLException {
        session.insert(queryName, param);
    }
}
