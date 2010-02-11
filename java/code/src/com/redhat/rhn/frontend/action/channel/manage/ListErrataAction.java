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
package com.redhat.rhn.frontend.action.channel.manage;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * AddErrataAction
 * @version $Rev$
 */
public class ListErrataAction extends RhnListAction implements Listable {

    private static final String ERRATA_DATA = "errata_data";
    private static final String CONFIRM = "channel.jsp.errata.remove";
    private static final String CID = "cid";

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getCurrentUser();

        PublishErrataHelper.checkPermissions(user);

        Long cid = Long.parseLong(request.getParameter(CID));
        Channel currentChan = ChannelFactory.lookupByIdAndUser(cid,
                requestContext.getCurrentUser());
        request.setAttribute("channel_name", currentChan.getName());


        //Make sure the user is a channel admin for the given channel.
        if (!UserManager.verifyChannelAdmin(user, currentChan)) {
            throw new PermissionCheckFailureException();
        }

        RhnSetDecl decl = RhnSetDecl.ERRATA_TO_REMOVE.createCustom(cid);



        ListRhnSetHelper helper = new ListRhnSetHelper(this, request, decl);
        helper.setDataSetName(ERRATA_DATA);
        helper.setWillClearSet(true);
        helper.execute();


        if (requestContext.wasDispatched(CONFIRM) && decl.get(user).size() > 0) {
            Map params = new HashMap();
            params.put(CID, cid);
            return getStrutsDelegate().forwardParams(mapping.findForward("submit"),
                    params);
        }


        request.setAttribute("cid", cid);
        return mapping.findForward("default");
    }



    /**
     *
     * {@inheritDoc}
     */
    public DataResult getResult(RequestContext context) {
        Long cid = Long.parseLong(context.getRequest().getParameter(CID));
        User user = context.getCurrentUser();
        Channel currentChan = ChannelFactory.lookupByIdAndUser(cid,
                context.getCurrentUser());
        return ChannelManager.listErrata(currentChan, null, null, user);
    }


}
