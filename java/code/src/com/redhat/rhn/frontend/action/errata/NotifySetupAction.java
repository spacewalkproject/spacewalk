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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.RequestContext;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * NotifySetupAction
 * @version $Rev$
 */
public class NotifySetupAction extends BaseErrataSetupAction {
    
    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        /*
         * Notifications can only be sent for a published errata.
         */
        Errata errata = new RequestContext(request).lookupErratum();
        if (!errata.isPublished()) {
            throw new BadParameterException("Unpublished errata.");
        }
        
        //return the default for errata
        return super.execute(mapping, formIn, request, response);
    }
}
