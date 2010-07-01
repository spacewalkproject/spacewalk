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

package com.redhat.rhn.common.translation;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.ConstraintViolationException;
import com.redhat.rhn.common.db.WrappedSQLException;

import java.sql.SQLException;

/**
 * Translator The class that actually does the object translations for us.
 *
 * @version $Rev$
 */

public class SqlExceptionTranslator extends Translations {

    private SqlExceptionTranslator() {
    }

    /**
     * Gets the appropriate runtime exception depending on whether the DB is oracle ornot
     * @param e the exception
     * @return the RuntimeExcetoion of the wrapped exception
     */
    public static RuntimeException sqlException(SQLException e) {
        if (ConfigDefaults.get().isOracle()) {
            return oracleSQLException(e);
        }
        else {
            return postgreSqlException(e);
        }
    }

    /**
     * Convert from PSQLException to some RuntimeException sub-class.
     *
     * @param e Exception to translate.
     * @return Translated RuntimeException with reference to the original.
     */
    private static RuntimeException postgreSqlException(SQLException e) {
        return new WrappedSQLException(e.getMessage(), e);
    }

    // This will currently only work for SQLException's that come from
    // Oracle.  To add more Databases, make this a private method, add a
    // public method with a different name, but the same signature, in the
    // new method, determine DB type, and call the correct translator.

    /**
     * Convert from SQLException to some other Exception type
     * @param e The SQLException to translate
     * @return The translated RuntimeException, which includes a reference
     *         to the SQLException that was passed in.
     */
    private static RuntimeException oracleSQLException(SQLException e) {
        int code = e.getErrorCode();
        String msg = e.getMessage();
        switch(code) {
            case 1:
                int ind = msg.indexOf("(") + 1;
                String desc = msg.substring(ind, msg.indexOf(")", ind));
                return new ConstraintViolationException(
                             ExceptionConstants.VALUE_TOO_LARGE, desc, msg, e);
            case 1401:
            case 12899:
                return new ConstraintViolationException(
                             ExceptionConstants.VALUE_TOO_LARGE, null, msg, e);
            default:
                return new WrappedSQLException(e.getMessage(), e);
        }
    }
}
