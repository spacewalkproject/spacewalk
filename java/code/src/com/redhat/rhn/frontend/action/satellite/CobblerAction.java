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

package com.redhat.rhn.frontend.action.satellite;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.satellite.CobblerSyncCommand;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * @author paji
 * @version $Rev$
 */
public class CobblerAction extends RhnAction {
    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        RequestContext ctx = new RequestContext(request);
        
        if (ctx.isSubmitted()) {
            CobblerSyncCommand cmd = new CobblerSyncCommand(ctx.getLoggedInUser());
            ValidatorError ve = cmd.store();
            if (ve == null) {
                addMessage(request, "cobbler.jsp.synced");    
            }
            else {
                ActionErrors errors = new ActionErrors();
                getStrutsDelegate().addError(errors, ve.getKey(), ve.getValues());
                getStrutsDelegate().saveMessages(request, errors);
            }
        }
        
        return mapping.findForward("default");
    }
}
