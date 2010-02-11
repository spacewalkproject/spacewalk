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
package com.redhat.rhn.manager.monitoring;

import com.redhat.rhn.common.util.Asserts;
import com.redhat.rhn.domain.monitoring.ServerProbe;
import com.redhat.rhn.domain.monitoring.command.Command;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;

/**
 * Command to create and then modify a server probe
 * @version $Rev$
 */
public class CreateServerProbeCommand extends ModifyProbeCommand {

    private SatCluster satCluster;
    private Server server;

    /**
     * Create a command that modifies a new probe. The probe is created for
     * <code>command</code> to run on <code>server</code> using the
     * SatCluster/scout <code>satCluster</code>.
     * 
     * @param userIn the user creating the probe
     * @param command the command underlying the probe
     * @param server0 the server to which the probe should be associated
     * @param satCluster0 the SatCluster with which the probe will communicate
     */
    public CreateServerProbeCommand(User userIn, Command command, Server server0,
            SatCluster satCluster0) {
        super(userIn, command, ServerProbe.newInstance());
        ServerProbe p = (ServerProbe) getProbe();
        p.setPendingState(satCluster0);
        Asserts.assertNotNull(server0, "server");
        Asserts.assertNotNull(satCluster0, "satCluster");
        server = server0;
        satCluster = satCluster0;
    }

    /**
     * {@inheritDoc}
     */
    public void storeProbe() {
        ((ServerProbe) getProbe()).addProbeToSatCluster(satCluster, server);
        super.storeProbe();
    }

}
