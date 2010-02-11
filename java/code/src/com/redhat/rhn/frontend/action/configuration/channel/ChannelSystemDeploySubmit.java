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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BaseSetOperateOnSelectedItemsAction;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ChannelSystemDeploySubmit
 * @version $Rev$
 */
public class ChannelSystemDeploySubmit extends BaseSetOperateOnSelectedItemsAction {

    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_CHANNEL_DEPLOY_SYSTEMS;
    }

    protected DataResult getDataResult(User user, ActionForm formIn,
            HttpServletRequest request) {
        User usr = new RequestContext(request).getLoggedInUser();
        ConfigChannel cc = ConfigActionHelper.getChannel(request);
        return ConfigurationManager.getInstance().listSystemInfoForChannel(usr, cc, null);
    }

    protected void processParamMap(ActionForm form, HttpServletRequest request, Map m) {
        ConfigChannel cc = ConfigActionHelper.getChannel(request);
        ConfigActionHelper.processParamMap(cc, m);
    }

    protected void processMethodKeys(Map map) {
        map.put("deploysystems.jsp.deployconfirmbutton", "doConfirm");
    }

    /**
     * User has pushed the "confirm" button
     * @param mapping Struts action-mapping
     * @param formIn associated form
     * @param request incoming request
     * @param response outgoing response
     * @return where we're supposed to go now
     */
    public ActionForward doConfirm(
            ActionMapping mapping,
            ActionForm formIn, 
            HttpServletRequest request,
            HttpServletResponse response) {
        RhnSet set = updateSet(request);
        //if they chose no systems, return to the same page with a message
        if (set.isEmpty()) {
            return handleEmptySelection(mapping, formIn, request);
        }
        Map params = makeParamMap(formIn, request);
        return getStrutsDelegate().forwardParams(mapping.findForward("confirm"), params);
    }
}
