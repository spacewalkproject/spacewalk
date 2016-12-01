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
public interface ParsedMode {

    /**
     * ModeType
     */
    enum ModeType {
        SELECT, WRITE, CALLABLE
    };

    /**
     * Get the name of this mode.
     * @return The name of this mode.
     */
    String getName();

    /**
     * Get the type of this mode.
     * @return the type of this mode.
     */
    ModeType getType();

    /**
     * Get the ParsedQuery instance associated with this mode.
     * @return The ParsedQuery instance associated with this
     * mode.
     */
    ParsedQuery getParsedQuery();

    /**
     * Get the name of the class used to return data from this
     * mode query.  If this is null, a map of name-value pairs
     * will be returned for each item in a query result.
     * @return The class to use when returning data from this
     * mode query.
     */
    String getClassname();

    /**
     * Get the list of elaborators that will be used to retrieve
     * additional data for each item in a primary/parent query
     * result.
     * @return The list of elaborators used to retrieve
     * additional data.
     */
    List<ParsedQuery> getElaborators();
}
