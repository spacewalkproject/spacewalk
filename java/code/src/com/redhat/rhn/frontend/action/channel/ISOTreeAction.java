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
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.filter.TreeFilter;
import com.redhat.rhn.frontend.listview.ListControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnUnpagedListAction;
import com.redhat.rhn.manager.channel.ChannelManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ISOTreeAction
 * @version $Rev$
 */
public class ISOTreeAction extends RhnUnpagedListAction {

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();
        DataResult dr = null;
        String fwd = "default";

        ListControl lc = new ListControl();

        filterList(lc, request, user);
        lc.setFilter(true);
        lc.setFilterColumn("name");
        lc.setCustomFilter(new TreeFilter());

        if (request.getRequestURI().indexOf("AllISOs") >= 0) {
            dr = ChannelManager.allDownloadsTree(user, lc);
            request.setAttribute("all", Boolean.TRUE);
            request.setAttribute("supported", Boolean.FALSE);
            request.setAttribute("retired", Boolean.FALSE);
        }
        else if (request.getRequestURI().indexOf("SupportedISOs") >= 0) {
            dr = ChannelManager.supportedDownloadsTree(user, lc);
            request.setAttribute("supported", Boolean.TRUE);
            request.setAttribute("all", Boolean.FALSE);
            request.setAttribute("retired", Boolean.FALSE);
        }
        else if (request.getRequestURI().indexOf("RetiredISOs") >= 0) {
            dr = ChannelManager.retiredDownloadsTree(user, lc);
            request.setAttribute("retired", Boolean.TRUE);
            request.setAttribute("all", Boolean.FALSE);
            request.setAttribute("supported", Boolean.FALSE);
        }
        request.setAttribute("pageList", dr);
        return mapping.findForward(fwd);
    }
}
