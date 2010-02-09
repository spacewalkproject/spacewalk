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

/**
 * A cached set of query/elaborator strings and the parameterMap hash maps.
 *
 * @version $Rev$
 */
public interface Mode {

    /**
     * Set the name for this mode.
     * @param n the name to set
     */
    void setName(String n);

    /**
     * get the name
     * @return the name
     */
    String getName();

    /**
     * Set the driving query for this mode.
     * @param q the query to set
     */
    void setQuery(CachedStatement q);

    /**
     * Get the driving query for this mode.
     * @return the driving query
     */
    CachedStatement getQuery();
}

