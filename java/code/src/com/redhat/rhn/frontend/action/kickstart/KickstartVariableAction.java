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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.builder.KickstartBuilder;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.BaseKickstartCommand;
import com.redhat.rhn.manager.kickstart.KickstartEditCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.cobbler.Profile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * KickstartDetailsEdit extends RhnAction
 * @version $Rev: 1 $
 */
public class KickstartVariableAction extends BaseKickstartEditAction {
    
    public static final String VARIABLES = "variables";

    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        KickstartData data = context.lookupAndBindKickstartData();
       
        return super.execute(mapping, formIn, request, response);
        
    }
    /**
     * {@inheritDoc}
     */
    protected void setupFormValues(RequestContext ctx, 
            DynaActionForm form, BaseKickstartCommand cmdIn) {
        KickstartEditCommand cmd = (KickstartEditCommand) cmdIn;

        
        CobblerXMLRPCHelper helper = new CobblerXMLRPCHelper();
        Profile prof = Profile.lookupById(helper.getConnection(
                ctx.getLoggedInUser()), cmd.getKickstartData().getCobblerId());
        form.set(VARIABLES, StringUtil.convertMapToString(prof.getKsMeta(), "\n"));
    }
        

    /**
     * {@inheritDoc}
     */
    protected ValidatorError processFormValues(HttpServletRequest request, 
            DynaActionForm form, 
            BaseKickstartCommand cmdIn) {
        
        ValidatorError error = null;
        KickstartEditCommand cmd = (KickstartEditCommand) cmdIn;
        RequestContext ctx = new RequestContext(request);
        KickstartBuilder builder = new KickstartBuilder(ctx.getLoggedInUser());
    
        try {
            CobblerXMLRPCHelper helper = new CobblerXMLRPCHelper();
            Profile prof = Profile.lookupById(helper.getConnection(
                    ctx.getLoggedInUser()), cmd.getKickstartData().getCobblerId());
            prof.setKsMeta(StringUtil.convertOptionsToMap((String)form.get(VARIABLES), 
                    "kickstart.jsp.error.invalidoption"));
            prof.save();
            
            return null;
        }
        catch (ValidatorException ve) {
            return ve.getResult().getErrors().get(0);
        }
    }

    protected String getSuccessKey() {
        return "kickstart.details.success";
    }

    /**
     * {@inheritDoc}
     */
    protected BaseKickstartCommand getCommand(RequestContext ctx) {
        return new KickstartEditCommand(ctx.getRequiredParam(RequestContext.KICKSTART_ID),
                ctx.getCurrentUser());
    }


    
}
