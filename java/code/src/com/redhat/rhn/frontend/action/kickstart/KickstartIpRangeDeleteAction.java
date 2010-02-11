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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.kickstart.KickstartIpCommand;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * KickstartIpRangeAction extends RhnAction
 * @version $Rev: 1 $
 */
public class KickstartIpRangeDeleteAction extends RhnAction {

    public static final String MIN = "min";
    public static final String MAX = "max";        
        
    /**
     * 
     * {@inheritDoc}
     */
    public final ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        Map params = makeParamMap(request);        
        RequestContext ctx = new RequestContext(request);
        User user = ctx.getCurrentUser();
        ActionErrors messages = new ActionErrors();
        
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        KickstartIpCommand cmd = 
            new KickstartIpCommand(ctx.getRequiredParam(RequestContext.KICKSTART_ID), 
                    ctx.getCurrentUser());
        
        // make sure get params came across request
        if ((request.getParameter(MIN)) == null ||
                (request.getParameter(MAX)) == null ||
                (ctx.getRequiredParam(RequestContext.KICKSTART_ID) == null)) {            
            throw new BadParameterException("Missing min, max and/or ksid for ks ip range");
        }
        // make sure org has permission
        else if (user.getOrg().getId() != 
            cmd.getKickstartData().getOrg().getId()) {              
            throw new BadParameterException("Invalid uid for /rhn/kickstart/");
        }
        // delete ip range from kickstart 
        else {            
            boolean success = cmd.deleteRange(cmd.getKickstartData().getId(), 
                    request.getParameter(MIN), 
                    request.getParameter(MAX));            
            if (success) {                
                createSuccessMessage(request, getSuccessKey(), 
                        cmd.getKickstartData().getLabel());
            }
            else {                                                
                messages.add(ActionMessages.GLOBAL_MESSAGE, 
                        new ActionMessage("kickstart.iprange_delete.failure", 
                                cmd.getKickstartData().getLabel()));
                strutsDelegate.saveMessages(request, messages);                
            }
        }
        
        request.setAttribute(RequestContext.KICKSTART, 
                cmd.getKickstartData());                                
        
        return strutsDelegate.forwardParams(mapping.findForward("default"),
                params);       
    }
    
    /**
     * 
     * @return i18n key
     */
    private String getSuccessKey() {
        return "kickstart.iprange_delete.success";        
    }     
                     
}
