/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ChannelTreeNode;
import com.redhat.rhn.frontend.filter.TreeFilter;
import com.redhat.rhn.frontend.listview.ListControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnUnpagedListAction;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

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

            request.setAttribute(RequestContext.PAGE_LIST, dr);
            request.setAttribute("satAdmin", user.hasRole(RoleFactory.SAT_ADMIN));
            addAttributes(requestContext);
            return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
        }

    protected abstract DataResult getDataResult(RequestContext requestContext,
            ListControl lc);

    /* override in subclasses if needed */
    protected void addAttributes(RequestContext requestContext) {
    }
}
