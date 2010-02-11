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
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * AddErrataAction
 * @version $Rev$
 */
public class ErrataRemoveAction extends RhnListAction implements Listable {

    private static final String CONFIRM = "channel.jsp.errata.confirmremove";
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

        requestContext.getRequiredParam(CID);

        Long cid = Long.parseLong(request.getParameter(CID));
        Channel currentChan = ChannelFactory.lookupByIdAndUser(cid,
                requestContext.getCurrentUser());


        //Make sure the user is a channel admin for the given channel.
        if (!UserManager.verifyChannelAdmin(user, currentChan)) {
            throw new PermissionCheckFailureException();
        }


        request.setAttribute("channel_name", currentChan.getName());


        RhnSetDecl decl = RhnSetDecl.ERRATA_TO_REMOVE.createCustom(cid);

        ListRhnSetHelper helper = new ListRhnSetHelper(this, request, decl);
        helper.setWillClearSet(false);
        helper.execute();

        request.setAttribute("cid", cid);

        if (requestContext.wasDispatched(CONFIRM)) {
           ChannelManager.removeErrata(currentChan, decl.get(user).getElementValues(),
                   user);
           Map params = new HashMap();
           params.put(CID, cid);

           ActionMessages msg = new ActionMessages();
           Set args = new HashSet();
           args.add(decl.get(user).size());
           msg.add(ActionMessages.GLOBAL_MESSAGE,
              new ActionMessage("channel.jsp.errata.remove.finalmessage", args.toArray()));

           getStrutsDelegate().saveMessages(request, msg);
           return getStrutsDelegate().forwardParams(mapping.findForward("submit"),
                   params);
        }
        return mapping.findForward("default");
    }


    /**
     *
     * {@inheritDoc}
     */
    public DataResult getResult(RequestContext context) {
        Long cid = Long.parseLong(context.getRequest().getParameter(CID));
        User user = context.getCurrentUser();
        RhnSetDecl decl = RhnSetDecl.ERRATA_TO_REMOVE.createCustom(cid);

        Channel currentChan = ChannelFactory.lookupByIdAndUser(cid,
                context.getCurrentUser());
        return ErrataManager.errataInSet(user, decl.getLabel());
    }


}
