/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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
import com.redhat.rhn.domain.channel.SelectableChannel;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * AddErrataAction
 * @version $Rev$
 */
public class ErrataCloneAction extends RhnListAction {

    private static final String CONFIRM = "channel.jsp.errata.clone.button";
    private static final String CID = "cid";
    private static final String LIST_NAME = "errata";
    private static final String DISPATCH = "dispatch";
    private static final String EMPTY_KEY = "channel.jsp.errata.clone.empty";

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext context = new RequestContext(request);
        User user = context.getCurrentUser();
        Long cid = Long.parseLong(request.getParameter(CID));
        Channel channel = ChannelFactory.lookupByIdAndUser(cid, user);

        PublishErrataHelper.checkPermissions(user, cid);

        request.setAttribute(CID, cid);
        request.setAttribute("user", user);
        request.setAttribute("channel_name", channel.getName());
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        request.setAttribute("emptyKey", EMPTY_KEY);

        List<SelectableChannel> channelList = null;

        RhnSet set = getDecl(channel).get(user);
        //if its not submitted
        // ==> this is the first visit to this page
        // clear the 'dirty set'
        if (!context.isSubmitted()) {
            set.clear();
            RhnSetManager.store(set);
        }

        Channel original = ChannelFactory.lookupOriginalChannel(channel);

        RhnListSetHelper helper = new RhnListSetHelper(request);
        if (request.getParameter(DISPATCH) != null) {
            // if its one of the Dispatch actions handle it..
            helper.updateSet(set, LIST_NAME);
            if (!set.isEmpty()) {
                Map<String, Object> params = new HashMap<String, Object>();
                params.put(CID, request.getParameter(CID));
                params.put(ConfirmErrataAction.SELECTED_CHANNEL, original.getId());
                return getStrutsDelegate().forwardParams(mapping.findForward("submit"),
                        params);
            }
            else {
                RhnHelper.handleEmptySelection(request);
            }
        }

        // get the errata list
        DataResult<ErrataOverview> dataSet = ErrataFactory.
                relevantToOneChannelButNotAnother(original.getId(), channel.getId());

        if (ListTagHelper.getListAction(LIST_NAME, request) != null) {
            helper.execute(set, LIST_NAME, dataSet);
        }

        if (!set.isEmpty()) {
            helper.syncSelections(set, dataSet);
            ListTagHelper.setSelectedAmount(LIST_NAME, set.size(), request);
        }

        request.setAttribute(RequestContext.PAGE_LIST, dataSet);
        ListTagHelper.bindSetDeclTo(LIST_NAME, getDecl(channel), request);
        TagHelper.bindElaboratorTo(LIST_NAME, dataSet.getElaborator(), request);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }


    protected RhnSetDecl getDecl(Channel chan) {
        return RhnSetDecl.setForChannelErrata(chan);
    }

}
