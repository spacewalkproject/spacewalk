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
package com.redhat.rhn.frontend.listview;

import com.redhat.rhn.frontend.taglibs.list.decorators.PageSizeDecorator;

/**
 * PageControl is a means of controlling how much data the user
 * sees in a list at a time. It also provides the filtering and indexing
 * mechanisms of ListControl
 * @version $Rev$
 */
public class PageControl extends ListControl {
    private int start;
    // The current user's page size.
    private int pageSize = DEFAULT_PER_PAGE;

    /** static value for default results per page. */
    public static final int DEFAULT_PER_PAGE = 25;
    
    /**
     * Get the number of entries desired in this list
     * @return Returns the end.
     */
    public int getEnd() {

        int end = start + pageSize - 1;
        if (end - start > PageSizeDecorator.MAX_PER_PAGE) {
            end = start + PageSizeDecorator.MAX_PER_PAGE;
        }

        return end;
    }

    /**
     * Set the page size for this list
     * @param ps The current user's desired page size.
     */
    public void setPageSize(int ps) {
        pageSize = ps;
    }
    
    /**
     * Get the first element in the list
     * @return Returns the start.
     */
    public int getStart() {
        return start;
    }
    
    /**
     * Set the first element in the list must be greater than 0.
     * @param s The start to set greater than 0.
     */
    public void setStart(int s) {
        if (s < 1) {
            throw new IllegalArgumentException("Start must be > 0");
        }
        this.start = s;
    }
}
