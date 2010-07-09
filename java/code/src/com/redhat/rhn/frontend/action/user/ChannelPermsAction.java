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
package com.redhat.rhn.frontend.action.user;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * AddressesAction Setup the Addresses on the Request so the AddressTag will be
 * able to render
 * @version $Rev$
 */
public class ChannelPermsAction extends RhnListAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        Long uid = requestContext.getParamAsLong("uid");
        DynaActionForm form = (DynaActionForm) formIn;
        String role = (String)form.get("role");
        if (uid == null || role.equals("")) {
            throw new BadParameterException("uid is null or role is empty string");
        }

        User user = UserManager.lookupUser(requestContext.getLoggedInUser(), uid);
        request.setAttribute(RhnHelper.TARGET_USER, user);

        String[] channels = (String[]) form.get("cid");
        String[] selected = (String[]) form.get("selectedChannels");

        List channelList = Arrays.asList(channels);
        List selectedList = Arrays.asList(selected);

        for (Iterator i = channelList.iterator(); i.hasNext();) {
            String currentChannel = (String) i.next();
            boolean isSet = selectedList.contains(currentChannel);

            if (isSet) {
                UserManager.removeChannelPerm(user, new Long(currentChannel), role);
                UserManager.addChannelPerm(user, new Long(currentChannel), role);
            }
            else {
                UserManager.removeChannelPerm(user, new Long(currentChannel), role);
            }

        }

        Map params = makeParamMap(request);

        params.put("uid", uid);
        params.put(RequestContext.FILTER_STRING,
                request.getParameter(RequestContext.FILTER_STRING));

        return strutsDelegate.forwardParams(mapping.findForward(role), params);
    }
}
