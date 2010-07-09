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
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
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
 * ChannelSystemsListSubmit
 * @version $Rev$
 */
public class ChannelSystemsListSubmit extends BaseSetOperateOnSelectedItemsAction {
    public static final String KEY_UNSUBSCRIBE = "channelsystems.jsp.unsubscribe";

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put(KEY_UNSUBSCRIBE, "processUnsubscribe");
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_SYSTEMS;
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User u, ActionForm formIn,
            HttpServletRequest request) {
        RequestContext ctx = new RequestContext(request);
        ConfigChannel cc = ConfigActionHelper.getChannel(ctx.getRequest());
        DataResult dr = ConfigurationManager.getInstance().
            listSystemInfoForChannel(u, cc, null);
        return dr;
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn,
                                   HttpServletRequest requestIn,
                                   Map paramsIn) {
        ConfigChannel cc = ConfigActionHelper.getChannel(requestIn);
        ConfigActionHelper.processParamMap(cc, paramsIn);
    }

    /**
     *
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward processUnsubscribe(
            ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        Map params = makeParamMap(formIn, request);
        operateOnSelectedSet(mapping, formIn, request, response, "unsubscribeSystems");
        RequestContext requestContext = new RequestContext(request);
        ConfigActionHelper.clearRhnSets(requestContext.getLoggedInUser());
        return getStrutsDelegate().forwardParams(mapping.findForward("success"), params);
    }

    /**
     * This method is called when the &quot;Unsubscribe from Channel&quot;
     * button is clicked in the Channel Systems page.
     * Unsubscribes the specified systems from the channel.
     * @param form Action form object.
     * @param req The servlet request object
     * @param elementIn The checked element in the set
     * @param userIn logged in user
     * @return true
     */
    public Boolean unsubscribeSystems(ActionForm form,
                                      HttpServletRequest req,
                                      RhnSetElement elementIn,
                                      User userIn) {
        ConfigChannel channel = ConfigActionHelper.getChannel(req);
        Server s = ServerFactory.lookupById(elementIn.getElement());
        s.unsubscribe(channel);
        ServerFactory.save(s);
        return Boolean.TRUE;
    }
}
