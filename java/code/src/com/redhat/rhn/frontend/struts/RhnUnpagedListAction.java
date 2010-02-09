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
package com.redhat.rhn.frontend.struts;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.listview.ListControl;

import javax.servlet.ServletRequest;

/**
 * RhnUnpagedListAction
 * @version $Rev$
 */
public class RhnUnpagedListAction extends RhnAction {
    
    /**
     * Sets up the ListControl filter data
     * @param lc ListControl to use
     * @param request ServletRequest
     * @param viewer user requesting the page
     */ 
    public void filterList(ListControl lc, ServletRequest request, User viewer) {
        /* 
         * Make sure we have a user. If not, something bad happened and we should
         * just bail out with an exception. Since this is probably the result of
         * a bad uid param, throw a BadParameterException. 
         */
        if (viewer == null) {
            throw new BadParameterException("Null viewer");
        }

        String filterData = request.getParameter(RequestContext.FILTER_STRING);
        
        if (filterData != null && !filterData.equals("")) {
            request.setAttribute("isFiltered", new Boolean(true));
        }
        else {
            request.setAttribute("isFiltered", new Boolean(false));
        }
            
        
        lc.setFilterData(filterData);
    }

}
