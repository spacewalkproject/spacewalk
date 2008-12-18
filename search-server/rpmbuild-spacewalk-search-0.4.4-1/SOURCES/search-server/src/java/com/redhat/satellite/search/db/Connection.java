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

import org.apache.log4j.Logger;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Simplified connection class for executing arbitrary SQL
 * 
 * @version $Rev$
 */
public class Connection {
    private static Logger log = Logger.getLogger(Connection.class);
    
    private SqlMapSession session;
    
    /**
     * Constructor
     * @param sess iBatis session to use
     */
    public Connection(SqlMapSession sess) {
        session = sess;
    }
    
    /**
     * Close down all resources
     * @throws SQLException something bad happened
     */
    public void close() throws SQLException {
        session.close();
    }
    
    /**
     * Executes a query
     * @param statement string of valid SQL
     * @param handler called on each row
     * @throws SQLException something bad happened
     */
    public void executeQuery(String statement, ResultHandler handler) throws SQLException {
        java.sql.Connection cn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            log.warn("start transaction");
            session.startTransaction();
            log.warn("get current connection");
            cn = session.getCurrentConnection();
            log.warn("creating statement");
            stmt = cn.createStatement();
            log.warn("execute query");
            rs = stmt.executeQuery(statement);
            log.warn("process resultset");
            while (rs.next()) {
                handler.handleRow(rs);
            }
        }
        finally {
            try {
                log.warn("commit transaction");
                session.commitTransaction();
            }
            finally {
                try {
                    if (rs != null) {
                        log.warn("close RS");
                        rs.close();
                    }
                }
                finally {
                    if (stmt != null) {
                        log.warn("close STMT");
                        stmt.close();
                    }
                }
            }
        }
    }
}
