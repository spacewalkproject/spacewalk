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
package com.redhat.rhn.frontend.action.rhnpackage.ssm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionForm;
import org.apache.log4j.Logger;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.rhnset.RhnSet;

/**
 * @version $Revision$
 */
public class SelectPackagesAction extends RhnAction {

    private static final String DATA_SET = "pageList";

    private final Logger log = Logger.getLogger(this.getClass());

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping actionMapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response)
        throws Exception {

        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();

        Long channelId = Long.parseLong(request.getParameter("cid"));
        DataResult dataSet = ChannelManager.latestPackagesInChannel(channelId);

        RhnSet set =  getSetDecl().get(user);
        if (!requestContext.isSubmitted()) {
            set.clear();
            RhnSetManager.store(set);
        }

        RhnListSetHelper helper = new RhnListSetHelper(request);
        if (ListTagHelper.getListAction("groupList", request) != null) {
            helper.execute(set, "groupList", dataSet);
        }

        if (!set.isEmpty()) {
            helper.syncSelections(set, dataSet);
            ListTagHelper.setSelectedAmount("result", set.size(), request);
        }

        request.setAttribute(DATA_SET, dataSet);
        request.setAttribute(ListTagHelper.PARENT_URL,
            request.getRequestURI());
        TagHelper.bindElaboratorTo("groupList", dataSet.getElaborator(),
            request);

        return actionMapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /**
     * Returns the set used to track selected packags to instal.
     *
     * @return will not be <code>null</code>
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.SSM_INSTALL_PACKAGE_LIST;
    }
}
