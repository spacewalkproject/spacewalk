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
package com.redhat.rhn.frontend.action.systems.monitoring;

import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.command.Command;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.monitoring.satcluster.SatClusterFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.CreateServerProbeCommand;
import com.redhat.rhn.manager.monitoring.ModifyProbeCommand;

import org.apache.struts.action.DynaActionForm;

import java.util.Map;

/**
 * ProbeCreateAction
 * @version $Rev$
 */
public class ProbeCreateAction extends BaseProbeCreateAction {

    private static final String SAT_CLUSTER_ID = "sat_cluster_id";

    /**
     * {@inheritDoc}
     */
    protected ModifyProbeCommand makeModifyProbeCommand(RequestContext ctx,
            DynaActionForm form, Command command) {
        Long satClusterID = (Long) form.get(SAT_CLUSTER_ID);
        SatCluster satCluster = SatClusterFactory.findSatClusterById(satClusterID);
        Server server = ctx.lookupAndBindServer();
        return new CreateServerProbeCommand(ctx.getCurrentUser(), command,
                server, satCluster);
    }

    /**
     * {@inheritDoc}
     */
    protected void addSuccessParams(RequestContext ctx, Map params, Probe probe) {
        params.put(PROBEID, probe.getId());
        params.put(RequestContext.SID, ctx.lookupAndBindServer().getId());
    }

    /**
     * {@inheritDoc}
     */
    protected void addAttributes(RequestContext ctx) {
        ctx.lookupAndBindServer();
    }

}
