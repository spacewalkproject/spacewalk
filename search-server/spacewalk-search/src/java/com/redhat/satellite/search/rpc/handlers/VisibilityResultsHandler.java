/**
 * Copyright (c) 2008--2010 Red Hat, Inc.
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

package com.redhat.satellite.search.rpc.handlers;

import com.redhat.satellite.search.db.ResultHandler;

import org.apache.log4j.Logger;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
/**
 * Cheesy class for screening hit results based
 * on user's security context
 * 
 * @version $Rev $
 */
class VisibilityResultsHandler implements ResultHandler {
    private static Logger log = Logger
            .getLogger(VisibilityResultsHandler.class);
    private List<String> results = new ArrayList<String>();
    
    
    /**
     * {@inheritDoc}
     */
    public void handleRow(ResultSet rs) throws SQLException {
        long id = rs.getLong(1);
        results.add(String.valueOf(id));
    }
    
    /**
     * Getter for accumulated results
     * @return results
     */
    List<String> getResults() {
        log.warn("returning results");
        return results;
    }
}
