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

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.frontend.action.systems.BaseSystemEditAction;
import com.redhat.rhn.frontend.action.systems.sdc.SdcHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.system.BaseSystemOperation;
import com.redhat.rhn.manager.system.CancelKickstartSessionOperation;

import org.apache.struts.action.DynaActionForm;

/**
 * SessionCancelAction - Action to cancel a Kickstart.
 * @version $Rev: 1 $
 */
public class SessionCancelAction extends BaseSystemEditAction {

    protected BaseSystemOperation getOperation(RequestContext ctx) {
        return new CancelKickstartSessionOperation(
                ctx.getCurrentUser(), ctx.getRequiredParam(RequestContext.SID));
    }

    protected ValidatorError processFormValues(DynaActionForm form, 
            BaseSystemOperation cmd) {
        return cmd.store();
    }

    /**
     * {@inheritDoc}
     */
    protected String getSuccessKey() {
        return "kickstart.session_cancel.success";
    }

    /**
     * {@inheritDoc}
     */
    protected void setupFormValues(RequestContext ctx, DynaActionForm form, 
            BaseSystemOperation cmd) {
        KickstartSession kss = KickstartFactory.
            lookupKickstartSessionByServer(cmd.getServer().getId());
        ctx.getRequest().setAttribute(RequestContext.KICKSTART_SESSION, kss);
        SdcHelper.ssmCheck(ctx.getRequest(), ctx.lookupServer().getId(), 
                ctx.getCurrentUser());
    }



}
