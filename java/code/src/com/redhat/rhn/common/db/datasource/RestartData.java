/**
 * Copyright (c) 2012 Red Hat, Inc.
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

import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * An object that stores data needed for a sql query so that it can be
 * restarted if necessary.
 * @author sherr
 */
public class RestartData implements Serializable {
    private static final long serialVersionUID = 1L;

    private Map<String, ?> parameters;
    private List<?> inClause;
    private Mode mode;

    /**
     * Create a RestartData for a query
     * @param parametersIn the parameters
     * @param inClauseIn the list of inClause values
     * @param modeIn the mode
     */
    public RestartData(Map<String, ?> parametersIn, List<?> inClauseIn, Mode modeIn) {
        this.parameters = parametersIn;
        this.inClause = inClauseIn;
        this.mode = modeIn;
    }

    /**
     * @return the parameters
     */
    public Map<String, ?> getParameters() {
        return parameters;
    }

    /**
     * @return the inClause
     */
    public List<?> getInClause() {
        return inClause;
    }

    /**
     * @return the Mode
     */
    public Mode getMode() {
        return mode;
    }
}
