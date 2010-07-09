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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.apache.struts.action.DynaActionForm;
import org.cobbler.CobblerObject;
import org.cobbler.Profile;

/**
 *
 * KickstartProfileVariableAction
 * @version $Rev$
 */
public class KickstartProfileVariableAction extends KickstartVariableAction {

    @Override
    protected CobblerObject getCobblerObject(String cobblerId, User user) {
        CobblerXMLRPCHelper helper = new CobblerXMLRPCHelper();
        return Profile.lookupById(helper.getConnection(user), cobblerId);
    }

    @Override
    protected String getCobblerId(RequestContext context) {
        Long ksid = context.getRequiredParam(RequestContext.KICKSTART_ID);
        KickstartData data = KickstartFactory.lookupKickstartDataByIdAndOrg(
                context.getLoggedInUser().getOrg(), ksid);
        if (data == null) {
            return null;
        }
        return data.getCobblerId();
    }

    @Override
    protected String getObjectString() {
        return RequestContext.KICKSTART_ID;
    }

    @Override
    /**
     * {@inheritDoc}
     */
    protected void setupFormValues(RequestContext ctx,
            DynaActionForm form, String cId) {
        super.setupFormValues(ctx, form, cId);
        Long ksid = ctx.getRequiredParam(RequestContext.KICKSTART_ID);
        KickstartData data = KickstartFactory.lookupKickstartDataByIdAndOrg(
                ctx.getLoggedInUser().getOrg(), ksid);
        ctx.getRequest().setAttribute("ksdata", data);
    }

}
