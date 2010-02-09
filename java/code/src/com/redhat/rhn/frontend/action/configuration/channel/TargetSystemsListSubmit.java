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
import com.redhat.rhn.common.localization.LocalizationService;
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
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * TargetSystemsListSubmit
 * Subscribes systems to a config-channel
 * @version $Rev:  $
 */
public class TargetSystemsListSubmit extends BaseSetOperateOnSelectedItemsAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User userIn, 
                                       ActionForm formIn, 
                                       HttpServletRequest requestIn) {
        RequestContext ctx = new RequestContext(requestIn);
        ConfigChannel cc = ConfigActionHelper.getChannel(requestIn);
        DataResult dr = ConfigurationManager.getInstance().
            listSystemsNotInChannel(ctx.getLoggedInUser(), cc, null);
        return dr;
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_TARGET_SYSTEMS;
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map mapIn) {
        mapIn.put("targetsystems.jsp.subscribe", "processSubscribe");
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
     * Subscribe the selected systems to the current cfg-channel
     * @param mapping struts ActionMapping
     * @param form struts ActionForm
     * @param request struts HttpServletRequest
     * @param response struts HttpServletResponse
     * @return The confirm ActionForward
     */
    public ActionForward processSubscribe(ActionMapping mapping,
                                          ActionForm form,
                                          HttpServletRequest request,
                                          HttpServletResponse response) {
        Map params = makeParamMap(form, request);
        operateOnSelectedSet(mapping, form, request, response, "subscribeSystems");
        //now some of the sets may be invalid, so delete them.
        RequestContext requestContext = new RequestContext(request);
        ConfigActionHelper.clearRhnSets(requestContext.getLoggedInUser());
        
        return getStrutsDelegate().forwardParams(mapping.findForward("success"), params);
    }
    
    /**
     * Attempts to subscribe the selected system to the current config-channel
     * Uses the userIn to check for permission errors.
     * @param formIn unused
     * @param requestIn unused
     * @param elementIn The RhnSetElement that contains the system's id
     * @param userIn The user requesting to delete config revisions.
     * @return Whether or not the subscription completed successfully. 
     */
    public Boolean subscribeSystems(ActionForm formIn, 
            HttpServletRequest requestIn,
            RhnSetElement elementIn, 
            User userIn) {
        
        ConfigChannel cc = ConfigActionHelper.getChannel(requestIn);
        Server s = ServerFactory.lookupById(elementIn.getElement());
        s.subscribe(cc);
        ServerFactory.save(s);
        
        // bz 444517 - Create a snapshot to capture this change
        String message =
            LocalizationService.getInstance().getMessage("snapshots.configchannel");
        SystemManager.snapshotServer(s, message);
        
        return Boolean.TRUE;
    }
}
