/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import javax.servlet.http.HttpServletRequest;


/**
 * @author paji
 * ListSessionSetHelper.java
 * @version $Rev$
 */
public class ListSessionSetHelper extends ListSetHelper {
   
    /**
     * Constructor
     * @param inp list submittable.
     */
    public ListSessionSetHelper(ListSubmitable inp) {
        super(inp);
    }

    @Override
    protected ListSetAdapter getAdapter(HttpServletRequest req,
            ListSubmitable ls) {
        return new SessionSetAdapter(req, ls);
    }
}
