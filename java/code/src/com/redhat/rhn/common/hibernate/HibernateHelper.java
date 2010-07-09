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
package com.redhat.rhn.common.hibernate;

import com.redhat.rhn.common.translation.SqlExceptionTranslator;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * A Database helper class to let us easily get connections
 *
 * @version $Rev: 1076 $
 */
public class HibernateHelper {

    // Can't construct
    private HibernateHelper() {
    }

    /**
     * Helper function for cleaning up all DB objects
     * @param rs JDBC ResultSet to be closed.
     */
    public static void cleanupDB(ResultSet rs) {
        cleanupDB(rs, null);
    }

    /**
     * Helper function for cleaning up all DB objects
     * @param stmt Statement to be closed.
     */
    public static void cleanupDB(Statement stmt) {
        cleanupDB(null, stmt);
    }

    /**
     * Helper function for cleaning up all DB objects
     * @param rs The resultSet to close
     * @param stmt The preparedStatement to close
     * @throws RuntimeException in case of SQLException
     */
    public static void cleanupDB(ResultSet rs, Statement stmt) throws RuntimeException {
        SQLException caught = null;
        try {
            if (rs != null) {
                rs.close();
            }
        }
        catch (SQLException e) {
            caught = e;
        }

        try {
            if (stmt != null) {
                stmt.close();
            }
        }
        catch (SQLException e) {
            caught = e;
        }

        if (caught != null) {
            throw SqlExceptionTranslator.sqlException(caught);
        }
    }
}
