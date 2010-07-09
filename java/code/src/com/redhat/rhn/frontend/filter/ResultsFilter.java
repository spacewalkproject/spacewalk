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
package com.redhat.rhn.frontend.filter;

import com.redhat.rhn.common.db.datasource.DataResult;

/**
 * ListFilter
 * ListFilters provide custom filtration logic for performing filtering on DataResult
 * lists. By default, ListControl filters all results that do not match the filter
 * data. While this is typically all the filtering needed, there are cases in which
 * we need to preserve results that would normally be filtered out. An example
 * would be a DataResult in which results have a parent/child relationship. We may
 * wish to preserve the parent of any child not filtered out. ListFilter allows
 * us to define such custom logic as necessary.
 * @version $Rev$
 */
public interface ResultsFilter {

    /**
     * @param dr DataResult to be filtered
     * @param filterData String to filter the DataResult with
     * @param filterColumn column to filter on
     */
    void filterData(DataResult dr, String filterData, String filterColumn);
}
