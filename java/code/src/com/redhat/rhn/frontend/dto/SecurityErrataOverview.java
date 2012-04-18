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
package com.redhat.rhn.frontend.dto;

import com.redhat.rhn.common.db.datasource.RowCallback;

import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 *  * SecurityErrataOverview
 *   * @version $Rev$
 *    */
public class SecurityErrataOverview extends ErrataOverview
                                    implements RowCallback {

    /**
     * {@inheritDoc}
     */
    public List<String> getCallBackColumns() {
        List<String> list = new ArrayList<String>();
        list.add("cve");
        return list;
    }

    /**
     * {@inheritDoc}
     */
    public void callback(ResultSet rs) throws SQLException {
        if (rs != null) {
            // need to use try-catch, because of use of two
            // elaborators (only one of them elaborates "CVE")
            try {
                ResultSetMetaData meta = rs.getMetaData();
                int columnCount = meta.getColumnCount();
                // make it faster by skipping the non-cve elaborators
                // expected errata_cves_elab returns 2 columns
                if (columnCount < 3) {
                    for (int i = 1; i <= columnCount; i++) {
                        if (meta.getColumnLabel(i).equals("cve")) {
                            String cve = rs.getString("cve");
                            if (cve != null) {
                                addCve(cve);
                            }
                        }
                    }
                }
            }
            catch (SQLException e) {
                return;
            }
        }
    }
}
