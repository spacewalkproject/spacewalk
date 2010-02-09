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

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.rhnpackage.PackageManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Collections;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * PackageNameOverviewAction
 * @version $Rev$
 */
public class PackageNameOverviewAction extends RhnAction {
    private static Logger log = Logger.getLogger(PackageNameOverviewAction.class);

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm form, 
            HttpServletRequest request, HttpServletResponse response) {
        String pkgName = request.getParameter("package_name");
        String subscribedChannels = request.getParameter("search_subscribed_channels");
        String channelFilter = request.getParameter("channel_filter");
        String[] channelArches = request.getParameterValues("channel_arch");
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        
        RequestContext ctx = new RequestContext(request);
        User user = ctx.getLoggedInUser();

        List dr = Collections.EMPTY_LIST;
        if (StringUtils.equals(subscribedChannels, "yes")) {
            dr = PackageManager.lookupPackageNameOverview(
                    user.getOrg(), pkgName);
        }
        else if (!StringUtils.isEmpty(channelFilter) &&
                StringUtils.equals(subscribedChannels, "no") &&
                channelArches == null) {
            Long filterChannelId = null;
            try {
                filterChannelId = Long.parseLong(channelFilter);
                dr = PackageManager.lookupPackageNameOverviewInChannel(user.getOrg(),
                        pkgName, filterChannelId);
            }
            catch (NumberFormatException e) {
                log.warn("Exception caught, unable to parse channel ID: " + channelFilter);
                dr = Collections.EMPTY_LIST;
            }
        }
        else if (channelArches != null && channelArches.length > 0) {
            dr = PackageManager.lookupPackageNameOverview(
                    user.getOrg(), pkgName, channelArches);
        }
        
        request.setAttribute("pageList", dr);

        return mapping.findForward("default");
    }
}
