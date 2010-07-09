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

import java.util.Map;

/**
 * A cached set of query/elaborator strings and the parameterMap hash maps.
 *
 * @version $Rev$
 */
public class CallableMode extends BaseMode {

    /**
     * Execute a stored procedure. In/Out parameters should be in BOTH
     * inParams and OutParams.
     * @param inParams A map of parameter names to values
     * @param outParams A map of parameter names to SQL Type
     * @return A map of all result parameters to the result value
     */
    public Map execute(Map inParams, Map outParams) {
        return getQuery().executeCallable(inParams, outParams);
    }
}

