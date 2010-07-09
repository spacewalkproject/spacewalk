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
import com.redhat.rhn.manager.kickstart.KickstartPartitionCommand;

import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;

/**
 * KickstartDetailsEdit extends RhnAction
 * @version $Rev: 1 $
 */
public class KickstartPartitionEditAction extends BaseKickstartEditAction {

    public static final String PARTITIONS = "partitions";


    /**
     * {@inheritDoc}
     */
    protected ValidatorError processFormValues(HttpServletRequest request,
            DynaActionForm form,
            BaseKickstartCommand cmdIn) {
        KickstartPartitionCommand cmd = (KickstartPartitionCommand) cmdIn;
        return cmd.parsePartitions(form.getString(PARTITIONS));
    }

    protected String getSuccessKey() {
        return "kickstart.partition.success";
    }

    /**
     * {@inheritDoc}
     */
    protected void setupFormValues(RequestContext ctx,
            DynaActionForm form, BaseKickstartCommand cmdIn) {
        KickstartPartitionCommand cmd = (KickstartPartitionCommand) cmdIn;
        form.set(PARTITIONS, cmd.populatePartitions());
    }

    /**
     * {@inheritDoc}
     */
    protected BaseKickstartCommand getCommand(RequestContext ctx) {
        return new KickstartPartitionCommand(
                ctx.getRequiredParam(RequestContext.KICKSTART_ID),
                ctx.getCurrentUser());
    }

}
