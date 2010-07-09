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

/**
 * PaginationUtil, contains utility functions for calcuating pagination.
 * @version $Rev$
 */

public class PaginationUtil {
    private int lower;
    private int upper;
    private int total;
    private int page;

    /**
     * Constructor
     * @param l current lower bound
     * @param u current upper bound
     * @param p page size
     * @param t total size
     */
    public PaginationUtil(int l, int u, int p, int t) {
        lower = l;
        upper = u;
        total = t;
        page = p == 0 ? 1 : p;
    }
    /**
     * Returns the 1 by default.
     * @return the 1 by default.
     */
    public String getFirstLower() {
        return "1";
    }

    /**
     * Returns the page size.
     * @return the page size.
     */
    public String getFirstUpper() {
        return String.valueOf(page);
    }

    /**
     * Returns the next lower limit.
     * @return the next lower limit.
     */
    public String getNextLower() {
        return String.valueOf(upper + 1);
    }

    /**
     * Returns the next upper limit.
     * @return the next upper limit.
     */
    public String getNextUpper() {
        int nu = upper + page;
        return nu > total ? String.valueOf(total) : String.valueOf(nu);
    }

    /**
     * Returns the previous lower limit.
     * @return the previous lower limit.
     */
    public String getPrevLower() {
        int pl = lower - page;
        return pl < 1 ? "1" : String.valueOf(pl);
    }

    /**
     * Returns the previous upper limit.
     * @return the previous upper limit.
     */
    public String getPrevUpper() {
        return String.valueOf(upper - page);
    }

    /**
     * Returns the last lower limit.
     * @return the last lower limit.
     */
    public String getLastLower() {
        int mod = total % page;
        if (mod == 0) {
            return String.valueOf(total - page + 1);
        }
        return String.valueOf(total - mod + 1);
    }

    /**
     * Returns the last upper limit.
     * @return the last upper limit.
     */
    public String getLastUpper() {
        return String.valueOf(total);
    }
}
