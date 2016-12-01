/**
 * Copyright (c) 2016 Red Hat, Inc.
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

/**
 * The DataSourceParserHelper creates an instance of this ParsedQuery for each
 * query it parses. The ParsedQuery is used by ModeFactory when creating new
 * Mode objects and the elaborators and queries contained therein.
 *
 * @version $Rev$
 */
public interface ParsedQuery {

    /**
     * Get the name of the query.
     * @return name of the query.
     */
    String getName();

    /**
     * Get the query's alias.
     * @return the query's alias.
     */
    String getAlias();

    /**
     * Get the sql statement as defined in the mode query
     * xml definition file.
     * @return the sql statement.
     */
    String getSqlStatement();

    /**
     * Get the elaborator join column.
     * NOTE: This value may not be used in anything but unit
     * tests as I only find case where this value is defined
     * outside of test_queries.xml and that is in
     * scap_queries.xml for a query named "testresult_counts".
     * @return the elaborator join column
     */
    String getElaboratorJoinColumn();

    /**
     * Get the list of parameters required by this query.
     * @return The list of parameters for this query.
     */
    List<String> getParameterList();

    /**
     * Determine if this elaborator can return multiple values
     * for each item in the primary query.
     * @return True if this elaborator can return multiple
     * for each item in the primary query, false otherwise.
     */
    boolean isMultiple();
}
