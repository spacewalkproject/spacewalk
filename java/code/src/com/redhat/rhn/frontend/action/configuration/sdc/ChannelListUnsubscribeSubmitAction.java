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
package com.redhat.rhn.frontend.action.configuration.sdc;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BaseSetOperateOnSelectedItemsAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * ChannelListUnsubscribeSubmitAction
 * @version $Rev$
 */
public class ChannelListUnsubscribeSubmitAction extends
        BaseSetOperateOnSelectedItemsAction {

    public static final String UNSUBSCRIBE_ACTION = "sdc.configlist.jsp.unsubscribe";

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user, ActionForm formIn,
            HttpServletRequest request) {
        RequestContext rctx = new RequestContext(request);
        Server server = rctx.lookupServer();
        return ConfigurationManager.getInstance().
                            listChannelsForSystem(user, server, null);
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_CHANNELS_TO_UNSUBSCRIBE;
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put(UNSUBSCRIBE_ACTION, "processUnsubscribeAction");

    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm form, HttpServletRequest request,
            Map params) {
        // TODO Auto-generated method stub

    }

    /**
     *
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward processUnsubscribeAction(ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        context.lookupAndBindServer();
        context.copyParamToAttributes(RequestContext.SID);

        return operateOnSelectedSet(mapping, formIn, request, response,
                "unsubscribe");
    }


    /**
     * This method is called when the &quot;Unsubscribe&quot;
     * button is clicked in the Channels List page.
     * Basically unsubscribes the selected channel.
     * @param form Action form object.
     * @param req The servlet request object
     * @param elementIn The checked element in the set
     * @param userIn logged in user
     * @return true of the server was entitled.
     */
    public Boolean unsubscribe(ActionForm form,
                                    HttpServletRequest req,
            RhnSetElement elementIn, User userIn) {

        Server server = (Server)req.getAttribute(RequestContext.SYSTEM);

        ConfigurationManager cm = ConfigurationManager.getInstance();
        ConfigChannel cc = cm.lookupConfigChannel(userIn, elementIn.getElement());

        int numOfChannels = server.getConfigChannels().size();
        server.unsubscribe(cc);

        // bz 444517 - Create a snapshot to capture this change
        String message =
            LocalizationService.getInstance().getMessage("snapshots.configchannel");
        SystemManager.snapshotServer(server, message);

        return Boolean.valueOf(numOfChannels > server.getConfigChannels().size());
    }
}
