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
package com.redhat.rhn.frontend.action.systems.provisioning.kickstart;

import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.kickstart.KickstartVariableAction;
import com.redhat.rhn.frontend.action.systems.sdc.SdcHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.cobbler.CobblerObject;
import org.cobbler.SystemRecord;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * EditVariablesAction
 * @version $Rev$
 */
public class VariablesAction extends KickstartVariableAction {
    private static final String NETBOOT_ENABLED = "netbootEnabled";
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        RequestContext ctx = new RequestContext(request);
        Server server = ctx.lookupAndBindServer();
        User user = ctx.getLoggedInUser();        
        SdcHelper.ssmCheck(ctx.getRequest(), server.getId(), user);
        DynaActionForm form = (DynaActionForm)formIn;
        SystemRecord rec = (SystemRecord) 
                        getCobblerObject(server.getCobblerId(), user);        
        if (isSubmitted(form)) {
            if (!Boolean.valueOf(rec.isNetbootEnabled()).
                                    equals(form.get(NETBOOT_ENABLED))) {
                rec.enableNetboot(Boolean.TRUE.equals(form.get(NETBOOT_ENABLED)));
                rec.save();
            }

        }
        form.set(NETBOOT_ENABLED, rec.isNetbootEnabled());
        return super.execute(mapping, formIn, request, response);
    }
    
    @Override
    protected void checkPermissions(HttpServletRequest request) {
        //TODO: check for null system record
    }
    
    @Override
    protected String getCobblerId(RequestContext context) {
        Server server = context.lookupAndBindServer();
        return server.getCobblerId();
    }

    @Override
    protected CobblerObject getCobblerObject(String cobblerId, User user) {
        return SystemRecord.lookupById(CobblerXMLRPCHelper.
                                    getConnection(user), cobblerId);
    }

    @Override
    protected String getObjectString() {
        return RequestContext.SID;
    }

}
