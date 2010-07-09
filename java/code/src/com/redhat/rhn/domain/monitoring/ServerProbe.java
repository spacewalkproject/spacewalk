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
package com.redhat.rhn.domain.monitoring;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.server.Server;

import java.util.Date;
import java.util.Set;

/**
 * ServerProbe - class that represents a ServerProbe that is assigned to a Server.
 * This class may have a parent, TemplateProbe if this ServerProbe is a
 * member of a ProbeSuite.
 * @version $Rev: 1 $
 */
public class ServerProbe extends Probe {

    // private Set serverProbeClusterAssociations;
    private Set templateProbes;
    private Server server;
    private SatCluster satCluster;

    /**
     * Creates new ServerProbe instance with appropriate defaults
     * @return ServerProbe
     */
    public static ServerProbe newInstance() {
        ServerProbe retval = new ServerProbe();
        retval.getType();
        return retval;
    }

    /**
     * Create a new server probe
     */
    public ServerProbe() {
        super();
    }

    /**
     * Get the Server used by this ServerProbe
     * @return Server used by this ServerProbe, NULL if not defined
     */
    public Server getServer() {
        /*ServerProbeClusterAssociation spca =
            getServerProbeClusterAssociation();
        return (spca == null) ? null : spca.getServer();*/
        return server;
    }

    /**
     * @param satClusterIn The satCluster to set.
     */
    public void setSatCluster(SatCluster satClusterIn) {
        this.satCluster = satClusterIn;
    }


    /**
     * @param serverIn The server to set.
     */
    public void setServer(Server serverIn) {
        this.server = serverIn;
    }

    /**
     * Get the SatCluster for this ServerProbe
     * @return SatCluster for the ServerProbe, or <code>null</code> if the probe is
     * not associated with a SatCluster
     */
    public SatCluster getSatCluster() {
        /*ServerProbeClusterAssociation spca =
            getServerProbeClusterAssociation();
        return (spca == null) ? null : spca.getSatCluster();*/
        return satCluster;
    }

    /**
     * @return Returns the type.
     */
    public ProbeType getType() {
        synchronized (this) {
            if (this.type == null) {
                setType(MonitoringConstants.getProbeTypeCheck());
            }
        }
        return this.type;
    }

    /*private ServerProbeClusterAssociation getServerProbeClusterAssociation() {
        // Since, in reality, the primary key for ServerProbeClusterAssociation
        // is ProbeId, we know that there will be only one SatCluster / ServerProbe.
        // Sucks that we have to map it this way, but, for some reason, they used
        // an assocation/mapping table to link a 1-to-1 relationship between ServerProbe
        Set spcaSet = getServerProbeClusterAssociations();
        if (spcaSet == null) {
            return null;
        }
        ServerProbeClusterAssociation spca = null;
        Iterator iter = spcaSet.iterator();
        if (iter.hasNext()) {
            spca = (ServerProbeClusterAssociation) iter.next();
        }
        return spca;
    }*/

    /**
     * Associate this probe with a SatCluster
     * @param satIn SatCluster to associate with this probe
     * @param serverIn Server that this ServerProbe should be tied to.
     */
    public void addProbeToSatCluster(SatCluster satIn, Server serverIn) {
        this.setSatCluster(satIn);
        this.setServer(serverIn);
        /*ServerProbeClusterAssociation newA = new ServerProbeClusterAssociation();
        newA.setProbe(this);
        newA.setProbeType(this.getType());
        newA.setSatCluster(satIn);
        newA.setServer(serverIn);
        this.addServerProbeClusterAssociation(newA);*/
    }

    /*private void addServerProbeClusterAssociation(ServerProbeClusterAssociation sIn) {
        if (this.serverProbeClusterAssociations == null) {
            this.serverProbeClusterAssociations = new HashSet();
        }
        this.serverProbeClusterAssociations.add(sIn);
    }*/

    /**
     * Used by this package to maintain the associations between Servers/SatClusters/Probes
     * @return Returns the serverProbeClusterAssociations.

    protected Set getServerProbeClusterAssociations() {
        return serverProbeClusterAssociations;
    }*/

    /**
     * Used by this package to maintain the associations between Servers/SatClusters/Probes
     * @param serverProbeClusterAssociationsIn The serverProbeClusterAssociations to set.

    protected void setServerProbeClusterAssociations(
            Set serverProbeClusterAssociationsIn) {
        this.serverProbeClusterAssociations = serverProbeClusterAssociationsIn;
    }*/

    /**
     * @return Returns the templateProbes.
     */
    private Set getTemplateProbes() {
        return templateProbes;
    }


    /**
     * @param templateProbesIn The templateProbes to set.
     */
    private void setTemplateProbes(Set templateProbesIn) {
        this.templateProbes = templateProbesIn;
    }

    /**
     * Get the TemplateProbe for this ServerProbe (the parent)
     * if there is one.
     * @return TemplateProbe instance if there is one.
     */
    public TemplateProbe getTemplateProbe() {
        if (getTemplateProbes() == null ||
                getTemplateProbes().size() == 0) {
            return null;
        }
        else {
            return (TemplateProbe)
                getTemplateProbes().iterator().next();
        }
    }

    /**
     *  Sets this probe to have a pending state.  Useful for new
     *  probes that you want to have a state of PENDING.
     *  @param clusterIn the SatCluster to use for the ProbeState
     */
    public void setPendingState(SatCluster clusterIn) {
        ProbeState state = new ProbeState(clusterIn);
        state.setState(MonitoringConstants.PROBE_STATE_PENDING);
        // Set to "Awaiting Update"
        state.setOutput(LocalizationService.getInstance().getMessage("probestate.pending"));
        state.setLastCheck(new Date());
        state.setProbe(this);
        this.setState(state);
    }

}
