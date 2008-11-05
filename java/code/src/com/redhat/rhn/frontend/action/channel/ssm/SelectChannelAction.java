/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.channel.ssm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.ListControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.channel.ChannelManager;

/**
 * Used in the first step of the SSM install package workflow, this action will
 * present the user with a list of all channels and allow one to be selected.
 *
 * @version $Revision$
 */
public class SelectChannelAction extends RhnListAction {

    private static final String DATA_SET = "pageList";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping actionMapping,
                                 ActionForm actionForm,
                                 HttpServletRequest httpServletRequest,
                                 HttpServletResponse httpServletResponse)
        throws Exception {

        RequestContext requestContext = new RequestContext(httpServletRequest);

        User user = requestContext.getLoggedInUser();
        ListControl lc = new ListControl();

        DataResult dataSet = ChannelManager.getChannelsForSsm(user, lc);

        httpServletRequest.setAttribute(ListTagHelper.PARENT_URL,
            httpServletRequest.getRequestURI());
        httpServletRequest.setAttribute(DATA_SET, dataSet);
        TagHelper.bindElaboratorTo("groupList", dataSet.getElaborator(),
            httpServletRequest);

        return actionMapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
}
