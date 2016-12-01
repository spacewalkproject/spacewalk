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

package com.redhat.rhn.frontend.taglibs.list;

import java.util.List;
import java.util.Locale;

/**
 * Defines the interface for filtering data in the ListTag
 * @version $Rev $
 */
public interface ListFilter {

    /**
     * Called before any other methods are called
     * @param userLocale locale of the requesting user
     */
    void prepare(Locale userLocale);

    /**
     * Returns the list of data bean field names the filter can filter on
     * It is the responsibility of the class implementing this interface to
     * provide any localization
     * @return List of field names
     */
    List getFieldNames();

    /**
     * Invoked on each object in the <b>complete</b> list of data beans
     * @param object Individual data beans
     * @param field field name to inspect
     * @param criteria filter criteria
     * @return true if the data bean passes, false if not
     */
    boolean filter(Object object, String field, String criteria);

    /**
     * Invoked after the list of filtered objects has been built and before
     * the list is returned from ListFilterHelper.
     * @param filteredList The filtered list
     */
    void postFilter(List filteredList);
}
