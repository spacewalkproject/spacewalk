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
package com.redhat.rhn.domain.monitoring.suite;

import com.redhat.rhn.domain.monitoring.ServerProbe;
import com.redhat.rhn.domain.monitoring.TemplateProbe;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;

import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

/**
 * ProbeSuite - Class representation of the table rhn_check_suites.
 * @version $Rev: 1 $
 */
public class ProbeSuite {

    private Long id;
    private String suiteName;
    private String description;
    private String lastUpdateUser;
    private Date lastUpdateDate;
    
    private Org org;
    private Set probes;
    
    /** 
     * Getter for recid 
     * @return Long to get
    */
    public Long getId() {
        return this.id;
    }

    /** 
     * Setter for id 
     * @param idIn to set
    */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /** 
     * Getter for suiteName 
     * @return String to get
    */
    public String getSuiteName() {
        return this.suiteName;
    }

    /** 
     * Setter for suiteName 
     * @param suiteNameIn to set
    */
    public void setSuiteName(String suiteNameIn) {
        this.suiteName = suiteNameIn;
    }

    /** 
     * Getter for description 
     * @return String to get
    */
    public String getDescription() {
        return this.description;
    }

    /** 
     * Setter for description 
     * @param descriptionIn to set
    */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }

    /** 
     * Getter for lastUpdateUser 
     * @return String to get
    */
    public String getLastUpdateUser() {
        return this.lastUpdateUser;
    }

    /** 
     * Setter for lastUpdateUser 
     * @param lastUpdateUserIn to set
    */
    public void setLastUpdateUser(String lastUpdateUserIn) {
        this.lastUpdateUser = lastUpdateUserIn;
    }

    /** 
     * Getter for lastUpdateDate 
     * @return Date to get
    */
    public Date getLastUpdateDate() {
        return this.lastUpdateDate;
    }

    /** 
     * Setter for lastUpdateDate 
     * @param lastUpdateDateIn to set
    */
    public void setLastUpdateDate(Date lastUpdateDateIn) {
        this.lastUpdateDate = lastUpdateDateIn;
    }

    /**
     * @return Returns the org.
     */
    public Org getOrg() {
        return org;
    }
    
    /**
     * @param orgIn The org to set.
     */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }
    /**
     * @return Returns the probes.
     */
    public Set getProbes() {
        if (this.probes == null) {
            return Collections.EMPTY_SET;
        } 
        else {
            return probes;
        }
    }
    
    /**
     * @param probesIn The probes to set.
     */
    public void setProbes(Set probesIn) {
        this.probes = probesIn;
    }
    
    /**
     * Add a ServerProbe to the suite.
     * @param probeIn ServerProbe to add.
     * @param currentUser the user adding the probe
     */
    public void addProbe(TemplateProbe probeIn, User currentUser) {
        if (this.probes == null || this.probes.size() == 0) {
            this.probes = new HashSet();
        }
        TemplateProbe model = null;
        if (!probes.isEmpty()) {
            model = (TemplateProbe) getProbes().iterator().next();
        }
        this.probes.add(probeIn);
        if (!equals(probeIn.getProbeSuite())) {
            probeIn.setProbeSuite(this, currentUser);
        }
        // Apply probeIn to all existing servers
        if (model != null && model.getServerProbes() != null) {
            for (Iterator i = model.getServerProbes().iterator(); i.hasNext();) {
                ServerProbe sp = (ServerProbe) i.next();
                applyProbe(probeIn, sp.getSatCluster(), sp.getServer(), currentUser);
            }
        }
    }
    
    /** 
     * Remove a ServerProbe from the Suite.
     * @param probeIn to remove.
     */
    public void removeProbe(TemplateProbe probeIn) {
        this.probes.remove(probeIn);
    }
    
    /**
     * Convenience method to add a Server to this ProbeSuite.
     * 
     * @param satCluster SatCluster we want to associate the ServerProbe with.
     * @param serverIn Server to add to the ProbeSuite.
     * @param currentUser who is adding the suite
     * 
     */
    public void addServerToSuite(SatCluster satCluster, Server serverIn, User currentUser) {
        
        // Loop through all the probes and add the Server to
        // each ServerProbe associated with this ProbeSuite.
        if (getProbes() == null || getProbes().size() == 0) {
            throw new IllegalArgumentException(
                    "Must add Probes to the Suite before we can add Servers");
        }
        Iterator i = getProbes().iterator();
        while (i.hasNext()) {
            TemplateProbe sProbe = (TemplateProbe) i.next();
            applyProbe(sProbe, satCluster, serverIn, currentUser);
        }
    }

    private void applyProbe(TemplateProbe probe, SatCluster satCluster,
            Server server, User currentUser) {
        ServerProbe newProbe = probe.deepCopy(currentUser);
        newProbe.setPendingState(satCluster);
        newProbe.addProbeToSatCluster(satCluster, server);
        probe.addServerProbe(newProbe);
    }
    
    /**
     * Get the Set of Server objects associated with this ProbeSuite
     * @return Set of Servers.
     */
    public Set getServersInSuite() {
        Set retval = new HashSet();
        // Loop through all the probes fetch the Servers
        // assigned to them.
        if (this.getProbes() == null) {
            return Collections.EMPTY_SET;
        }
        Iterator i = getProbes().iterator();
        while (i.hasNext()) {
            TemplateProbe probe = (TemplateProbe) i.next();
            Set servers = probe.getServersUsingProbe();
            retval.addAll(servers);
        }
        return retval;
    }
}
