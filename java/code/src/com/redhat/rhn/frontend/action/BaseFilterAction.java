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
package com.redhat.rhn.frontend.action;

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * BaseFilterAction
 * 
 * Abstract class for functionality to be shared amongst actions that 
 * perform filtering.
 * @version $Rev$
 */
public abstract class BaseFilterAction extends RhnAction {
    
    /**
     * Retrieve filter related values from the request context and add 
     * appropriate values to the parameter map.
     * @param params Parameter map to add filter data to.
     * @param request Request object to extract filter data from.
     */
    public void processFilterParameters(Map params, HttpServletRequest request) {
        String filterValue = request.getParameter(RequestContext.FILTER_STRING);
        String prevFilterValue = request.getParameter(
                RequestContext.PREVIOUS_FILTER_STRING);
        
        String data = null;
        if (prevFilterValue != null) {
            data = prevFilterValue;
        }
        
        if (filterValue != null) {
            // If our filter data changes, then reset the list back to the start,
            if (!filterValue.equals(data)) {
                params.put("lower", "1");
            }
            data = filterValue;
        }
        
        if (data != null) {
            params.put("filter_string", data);
        }
    }

}
