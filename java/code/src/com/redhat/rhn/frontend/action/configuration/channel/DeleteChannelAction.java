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
package com.redhat.rhn.frontend.action.configuration.channel;

import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * DeleteChannelAction extends RhnAction
 * Re
 * @version $Rev: 1 $
 */
public class DeleteChannelAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext rctx = new RequestContext(request);
        User user = rctx.getLoggedInUser();
        DynaActionForm daForm = (DynaActionForm)formIn;
        Map params = makeParamMap(request);
        
        ConfigChannel cc = ConfigActionHelper.getChannel(request);
        
        if (cc != null) {
            if (isSubmitted(daForm)) {
                deleteChannel(request, cc);
                //Now that the config channel is gone, some of these sets may no longer
                //be valid, so clear them.
                ConfigActionHelper.clearRhnSets(user);
                return getStrutsDelegate().forwardParams(mapping.findForward("submit"), 
                        params);
            }
            else {
                rctx.getRequest().setAttribute("currChannel", cc);
            }
            ConfigActionHelper.setupRequestAttributes(rctx, cc);
        }
        
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }

    private void deleteChannel(HttpServletRequest request, ConfigChannel cc) {
        RequestContext requestContext = new RequestContext(request);
        
        User u = requestContext.getLoggedInUser();
        ConfigurationManager.getInstance().deleteConfigChannel(u, cc);
    }
}
