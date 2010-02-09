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

import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.frontend.events.RestartSatelliteEvent;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;

import org.apache.commons.lang.BooleanUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * RestartAction extends RhnAction - Class representation of the table ###TABLE###.
 * @version $Rev: 1 $
 */
public class RestartAction extends RhnAction {
    
    public static final String RESTART = "restart";
    public static final String RESTARTED = "restarted";
    public static final String RESTART_DELAY_LABEL = "restartDelay";
    public static final int RESTART_DELAY_IN_MINUTES = 1;
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
  
        DynaActionForm form = (DynaActionForm) formIn;
        RequestContext ctx = new RequestContext(request);
        
        if (isSubmitted(form)) {
            Boolean restart = ((Boolean) form.get(RESTART));
            if (BooleanUtils.toBooleanDefaultIfNull(restart, false)) {
                RestartSatelliteEvent event = new 
                    RestartSatelliteEvent(ctx.getCurrentUser());
                MessageQueue.publish(event);
                createSuccessMessage(request, "restart.config.success", 
                                    String.valueOf(RESTART_DELAY_IN_MINUTES));
                request.setAttribute(RESTART, Boolean.TRUE);
                request.setAttribute(RESTART_DELAY_LABEL, 
                                    String.valueOf(RESTART_DELAY_IN_MINUTES * 60));
            }
            else {
                addMessage(request, "restart.config.norestart");
                request.setAttribute(RESTART, Boolean.FALSE);
            }
        }
        else {
            if (request.getParameter(RESTARTED) != null &&
                request.getParameter(RESTARTED).equals("true")) {
                addMessage(request, "restart.config.restarted");
            }
            
            form.set(RESTART, Boolean.FALSE);
            request.setAttribute(RESTART, Boolean.FALSE);
        }

        return mapping.findForward("default");
    }

}
