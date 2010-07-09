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
package com.redhat.rhn.frontend.action.channel;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ChannelTreeNode;
import com.redhat.rhn.frontend.filter.TreeFilter;
import com.redhat.rhn.frontend.listview.ListControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnUnpagedListAction;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BaseChannelTreeSetupAction
 * @version $Rev$
 */
public abstract class BaseChannelTreeAction extends RhnUnpagedListAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

            RequestContext requestContext = new RequestContext(request);

            User user = requestContext.getLoggedInUser();
            ListControl lc = new ListControl();

            filterList(lc, request, user);
            lc.setFilter(true);
            lc.setFilterColumn("name");
            lc.setCustomFilter(new TreeFilter());
            DataResult<ChannelTreeNode> dr = getDataResult(requestContext, lc);
            Collections.sort(dr);
            dr = handleOrphans(dr);

            request.setAttribute("pageList", dr);
            request.setAttribute("satAdmin", user.hasRole(RoleFactory.SAT_ADMIN));
            addAttributes(requestContext);
            return mapping.findForward("default");
        }

    protected abstract DataResult getDataResult(RequestContext requestContext,
            ListControl lc);

    /* override in subclasses if needed */
    protected void addAttributes(RequestContext requestContext) {
    }

    /**
     * Handle the orphan'd child channels by adding a "fake" node
     *   This is done because a child can be viewable when the parent is not
     * @param result
     */
    protected DataResult<ChannelTreeNode> handleOrphans(
            DataResult<ChannelTreeNode> result) {

        DataResult<ChannelTreeNode> toReturn =
                new DataResult<ChannelTreeNode>(new ArrayList());
        toReturn.setFilter(true);
        toReturn.setFilterData(result.getFilterData());

        //We want the orphans to be at the end of the list, so lets add them here
        //   and then add them to the whole list later
        List<ChannelTreeNode> orphans = new ArrayList<ChannelTreeNode>();


        ChannelTreeNode lastParent = null;
        ChannelTreeNode lastOrphan = null;

        for (ChannelTreeNode node : result) {
            //if the node is a parent, mark it as last and move on
            if (node.isParent()) {
                lastParent = node;
                toReturn.add(node);
            } //if the node is a child of previous parent, move on
            else if (lastParent != null && node.getParentId().equals(lastParent.getId())) {
                toReturn.add(node);
            } //else we couldn't find the previous parent (so it's probably not here :{)
            else {
                //If this is the first orphan or the parent of the last orphan doesn't
                //  match this orphan's parent, then we need to add a node for the
                //  restriciton
               if (lastOrphan == null ||
                       !lastOrphan.getParentId().equals(node.getParentId())) {
                   orphans.add(newRestrictedParent(node));
                   orphans.add(node);
               } //else this orphan has the same parent as the last, so no new dummy node
               else {
                   orphans.add(node);
               }
               lastOrphan = node;
            }
        }
        toReturn.addAll(orphans);
        return toReturn;
    }

    private ChannelTreeNode newRestrictedParent(ChannelTreeNode child) {
        ChannelTreeNode parent;
        parent = new ChannelTreeNode();
        parent.setAccessible(false);
        parent.setName(LocalizationService.getInstance().getMessage(
                "channel.unavailable"));
        parent.setId(child.getParentId());
        parent.setParentId(null);
        return parent;
    }

}
