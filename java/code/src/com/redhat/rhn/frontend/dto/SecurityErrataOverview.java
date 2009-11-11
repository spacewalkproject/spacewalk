/**
 * Copyright (c) 2009 Red Hat, Inc.
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
        list.add("CVE".toLowerCase());
        return list;
    }

    /**
     * {@inheritDoc}
     */
    public void callback(ResultSet rs) throws SQLException {
        if (rs != null) {
            String cve = rs.getString("CVE");
            if (cve != null) {
                    addCve(cve);
            }
        }
    }
}
