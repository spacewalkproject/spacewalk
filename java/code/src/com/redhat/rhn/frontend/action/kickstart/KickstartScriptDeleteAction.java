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

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.BaseKickstartCommand;
import com.redhat.rhn.manager.kickstart.KickstartScriptDeleteCommand;

import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;

/**
 * KickstartScriptDeleteAction - Action to delete a KickstartScript
 * @version $Rev: 1 $
 */
public class KickstartScriptDeleteAction extends BaseKickstartEditAction {

    public static final String KICKSTART_SCRIPT = "ksscript";


    protected BaseKickstartCommand getCommand(RequestContext ctx) {
        return new KickstartScriptDeleteCommand(
                ctx.getRequiredParam(RequestContext.KICKSTART_ID),
                ctx.getRequiredParam(RequestContext.KICKSTART_SCRIPT_ID),
                ctx.getCurrentUser());
    }

    /**
     * {@inheritDoc}
     */
    protected ValidatorError processFormValues(HttpServletRequest request,
            DynaActionForm form,
            BaseKickstartCommand cmd) {
        return null;
    }

    /**
     * {@inheritDoc}
     */
    protected String getSuccessKey() {
        return "kickstart.script.delete";
    }

    /**
     * {@inheritDoc}
     */
    protected String getSuccessForward() {
        return "success";
    }


    /**
     * {@inheritDoc}
     */
    protected void setupFormValues(RequestContext ctx, DynaActionForm form,
            BaseKickstartCommand cmd) {
        KickstartScriptDeleteCommand dcmd = (KickstartScriptDeleteCommand) cmd;
        ctx.getRequest().setAttribute(KICKSTART_SCRIPT, dcmd.getScript());
    }


}
