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

import java.util.List;
import java.util.Map;

/**
 * A cached set of query/elaborator strings and the parameterMap hash maps.
 *
 * @version $Rev$
 */
public class WriteMode extends BaseMode {

    /**
     * Executes the update statement with the given query parameters.
     * @param parameters Query parameters.
     * @return int number of rows affected.
     */
    public int executeUpdate(Map parameters) {
        return getQuery().executeUpdate(parameters);
    }
    
    
    /**
     * execute an update with an inClause (%s).
     *  This handles more than 1000 items in teh in clause 
     * @param parameters the query parameters
     * @param inClause the in clause
     * @return the number of rows updated/inserted/deleted
     */
    public int executeUpdate(Map parameters, List inClause) {
        int subStart = 0;
        int toReturn = 0;
        while (subStart < inClause.size()) {
            int subLength = subStart + CachedStatement.BATCH_SIZE >= inClause.size() ? 
                    inClause.size() - subStart  : CachedStatement.BATCH_SIZE;
            List subClause = inClause.subList(subStart, subStart + subLength);
            toReturn += getQuery().executeUpdate(parameters, subClause);
            subStart += subLength;
        }       
        return toReturn;
    }
    
}

