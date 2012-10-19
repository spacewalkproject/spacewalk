/**
 * Copyright (c) 2012 Red Hat, Inc.
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

import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.DistChannelMap;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * DistChannelMapDeleteAction
 * @version $Rev$
 */
public class DistChannelMapDeleteAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
        RequestContext ctx = new RequestContext(request);
        User user = ctx.getLoggedInUser();

        Long dcmId = ctx.getRequiredParam("dcm");

        DistChannelMap dcMapping = ChannelFactory.lookupDistChannelMapById(dcmId);
        ctx.getRequest().setAttribute("dcmap", dcMapping);

        if (ctx.isSubmitted()) {
            if (dcMapping != null && dcMapping.getOrg() != null) {
                createSuccessMessage(request, "distchannelmap.jsp.delete.message",
                        dcMapping.getOs());
                ChannelFactory.remove(dcMapping);
                return mapping.findForward("success");
            }
            createErrorMessage(request, "distchannelmap.jsp.delete.default.message",
                    null);
        }
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
}
