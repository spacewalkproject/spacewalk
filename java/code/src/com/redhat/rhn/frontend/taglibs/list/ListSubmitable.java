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

import com.redhat.rhn.frontend.struts.RequestContext;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * @author paji
 * ListSubmitable
 * @version  $Rev$
 */
public interface ListSubmitable extends Listable {
    /**
     * Basically performs the action that occurs 
     * when a dispatch button is clicked.
     * @param mapping the Action mapping
     * @param formIn the submitted form 
     * @param request  the servlet request
     * @param response the servlet response
     * @return the appropriate action forward
     */
    ActionForward handleDispatch(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response);

    /**
     * Returns a set declaration name associated to this List
     * @param context the request context
     * @return the set declaration name
     */
    String getDecl(RequestContext context);
    
}
