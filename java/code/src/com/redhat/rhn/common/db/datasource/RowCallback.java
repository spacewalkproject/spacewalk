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
package com.redhat.rhn.common.db.datasource;

import java.sql.ResultSet;
import java.sql.SQLException;

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
}
