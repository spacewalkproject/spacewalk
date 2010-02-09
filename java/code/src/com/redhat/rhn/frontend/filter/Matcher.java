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


/**
 * An interface used by TreeFilter right now 
 * but may be useful in the future that matches a filter data
 * and a filter column on each element and determines
 * if an element in a list can be included or filtered.
 * This facility was added so that we could evaluate things like
 * if a given DTO had a condition x match on column X, 
 * else match on column Y.
 * Matcher
 * @version $Rev$
 */
public interface Matcher {
    /**
     * Return true if given an individual object, 
     *     a filterData and filter column if the object should be 
     *     included in the final list.  
     * @param obj each item of a dataresult to be filtered.. Most likely a DTO 
     * @param filterData the value of the column that is being queried  
     * @param filterColumn the name of the column being queried
     * @return true if the input row for this object is to be included 
     *              in the post filtered list.. 
     */
     boolean include(Object obj, String filterData, String filterColumn);
    
     /**
      * The default matcher user for almost all string evaluations
     */
     Matcher DEFAULT_MATCHER = new StringMatcher();
}
