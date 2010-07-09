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

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

/**
 * RowCallback is called for each row found in the ResultSet of an
 * elaborator query.
 * @version $Rev$
 * @see com.redhat.rhn.common.db.datasource.CachedStatement
 */
public interface RowCallback {

    /**
     * Callback method which is invoked by DataSource for each row found
     * in the ResultSet of an elaborator query. The implementor should
     * NOT attempt to loop through or close the ResultSet.
     * @param rs ResultSet containing current row returned by elaborator.
     * @throws SQLException thrown if there is a problem accessing the
     * ResultSet.
     */
    void callback(ResultSet rs) throws SQLException;

    /**
     * A list of column names that are used in the callback In lower case.
     * All other column names will be processed normally.
     * For use if you want to use callback to process some columns,
     * but still want other columns to be set (with  setBLAH)
     *
     * @return the list of columns to skip (that are used by callback)
     */
    List<String> getCallBackColumns();

}
