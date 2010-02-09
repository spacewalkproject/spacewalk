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

import com.redhat.rhn.domain.monitoring.command.CommandParameter;
import com.redhat.rhn.domain.monitoring.notification.ContactGroup;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.collections.Closure;
import org.apache.commons.collections.ClosureUtils;
import org.apache.commons.collections.CollectionUtils;

import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

/**
 * TemplateProbe - subclass of ServerProbe that includes ServerProbe Suite
 * functionality.  All Probes of ProbeType == 'suite' are 
 * instantiated as this class.
 * @version $Rev: 1 $
 */
public class TemplateProbe extends Probe {
    
    private List serverProbes;
    private Set probeSuites;
    
    /**
     * Creates new TemplateProbe instance with appropriate defaults
     * @return TemplateProbe
     */    
    public static TemplateProbe newInstance() {
        TemplateProbe retval = new TemplateProbe();
        retval.getType();
        return retval;
    }

    /**
     * Create a new template probe
     */
    public TemplateProbe() {
        super();
    }
    
    /**
     * @return Returns the serverProbes.
     */
    public List getServerProbes() {
        // We would like to lazily initialize serverProbes here, or
        // even better, return Collections.EMPTY_LIST. But both seem
        // to confuse hibernate and lead to failures in ProbeSuiteTest
        return serverProbes;
    }
    
    /**
     * @param serverProbesIn The serverProbes to set.
     */
    public void setServerProbes(List serverProbesIn) {
        this.serverProbes = serverProbesIn;
    }
    
    /**
     * Add a new standard ServerProbe to this TemplateProbe.  The 
     * passed in ServerProbe should be associated with a Server and
     * SatCluster, IOTW, a standard probe.
     * @param probeIn ServerProbe we want to add
     */
    public void addServerProbe(ServerProbe probeIn) {
        if (this.serverProbes == null) {
            this.serverProbes = new LinkedList();
        }
        this.serverProbes.add(probeIn);
    }
    
    /**
     * Remove a Server's ServerProbe from this TemplateProbe
     * @param probeIn ServerProbe to remove
     */
    public void removeServerProbe(ServerProbe probeIn) {
        this.serverProbes.remove(probeIn);
    }
    
    /**
     * Convenience method to get the Servers using this ServerProbe
     * @return Set of Servers using this probe
     */
    public Set getServersUsingProbe() {
        if (this.serverProbes == null) {
            return Collections.EMPTY_SET;
        }
        Iterator i = getServerProbes().iterator();
        Set retval = new HashSet();
        while (i.hasNext()) {
            ServerProbe p = (ServerProbe) i.next(); 
            retval.add(p.getServer());
        }
        return retval;
    }
    
    /**
     * UsupportedOperation in ProbeTemplate.  No Servers are directly 
     * associated with a ProbeTemplate
     * @return Server n/a - not supported
     */
    public Server getServer() {
        throw new UnsupportedOperationException(
                "No Servers are directly associated with a ProbeTemplate"); 
 
    }

    /***** OVERRIDDEN METHODS TO UPDATE ALL THE PROBES IN THE SUITE *******/
    
    /**
     * {@inheritDoc}
     */
    public void setCheckIntervalMinutes(Long checkIntervalMinutesIn) {
        super.setCheckIntervalMinutes(checkIntervalMinutesIn);
        forAllProbes("setCheckIntervalMinutes", Long.class, checkIntervalMinutesIn);
    }

    /**
     * {@inheritDoc}
     */
    public void setCommandParameterValue(CommandParameter paramIn, String valueIn) {
        super.setCommandParameterValue(paramIn, valueIn);
        Closure c = ClosureUtils.invokerClosure("setCommandParameterValue", 
                new Class[] { CommandParameter.class, String.class }, 
                new Object[] { paramIn, valueIn });
        CollectionUtils.forAllDo(getServerProbes(), c);        
    }

    /**
     * {@inheritDoc}
     */
    public void setContactGroup(ContactGroup contactGroupIn) {
        super.setContactGroup(contactGroupIn);
        forAllProbes("setContactGroup", ContactGroup.class, contactGroupIn);
    }

    /**
     * {@inheritDoc}
     */
    public void setDescription(String descriptionIn) {
        super.setDescription(descriptionIn);
        forAllProbes("setDescription", String.class, descriptionIn);
    }

    /**
     * {@inheritDoc}
     */
    public void setLastUpdateDate(Date lastUpdateDateIn) {
        super.setLastUpdateDate(lastUpdateDateIn);
        forAllProbes("setLastUpdateDate", Date.class, lastUpdateDateIn);
    }

    /**
     * {@inheritDoc}
     */
    public void setLastUpdateUser(String lastUpdateUserIn) {
        super.setLastUpdateUser(lastUpdateUserIn);
        forAllProbes("setLastUpdateUser", String.class, lastUpdateUserIn);
    }

    /**
     * {@inheritDoc}
     */
    public void setMaxAttempts(Long maxAttemptsIn) {
        super.setMaxAttempts(maxAttemptsIn);
        forAllProbes("setMaxAttempts", Long.class, maxAttemptsIn);
    }

    /**
     * {@inheritDoc}
     */
    public void setNotificationIntervalMinutes(Long notificationIntervalMinutesIn) {
        super.setNotificationIntervalMinutes(notificationIntervalMinutesIn);
        forAllProbes("setNotificationIntervalMinutes", Long.class, 
                notificationIntervalMinutesIn);
    }

    /**
     * {@inheritDoc}
     */
    public void setNotifyCritical(Boolean notifyCriticalIn) {
        super.setNotifyCritical(notifyCriticalIn);
        forAllProbes("setNotifyCritical", Boolean.class, notifyCriticalIn);
    }

    /**
     * {@inheritDoc}
     */
    public void setNotifyRecovery(Boolean notifyRecoveryIn) {
        super.setNotifyRecovery(notifyRecoveryIn);
        forAllProbes("setNotifyRecovery", Boolean.class, notifyRecoveryIn);
    }

    /**
     * {@inheritDoc}
     */
    public void setNotifyUnknown(Boolean notifyUnknownIn) {
        super.setNotifyUnknown(notifyUnknownIn);
        forAllProbes("setNotifyUnknown", Boolean.class, notifyUnknownIn);
    }

    /**
     * {@inheritDoc}
     */
    public void setNotifyWarning(Boolean notifyWarningIn) {
        super.setNotifyWarning(notifyWarningIn);
        forAllProbes("setNotifyWarning", Boolean.class, notifyWarningIn);
    }

    /**
     * {@inheritDoc}
     */
    public void setOrg(Org orgIn) {
        super.setOrg(orgIn);
        forAllProbes("setOrg", Org.class, orgIn);
    }

    /**
     * {@inheritDoc}
     */
    public void setRetryIntervalMinutes(Long retryIntervalMinutesIn) {
        super.setRetryIntervalMinutes(retryIntervalMinutesIn);
        forAllProbes("setRetryIntervalMinutes", Long.class, retryIntervalMinutesIn);        
    }

    private void forAllProbes(String setter, Class valueClass, Object value) {
        Closure c = ClosureUtils.invokerClosure(setter, 
                new Class[] { valueClass }, 
                new Object[] { value });
        CollectionUtils.forAllDo(getServerProbes(), c);
    }

    /**
     * {@inheritDoc}
     */
    public void setParameterValue(ProbeParameterValue ppv, String value) {
        super.setParameterValue(ppv, value);
        String paramName = ppv.getParamName();
        List probes = getServerProbes();
        if (probes != null) {
            for (int i = 0; i < probes.size(); i++) {
                ServerProbe p = (ServerProbe) probes.get(i);
                p.setParameterValue(p.findParameter(paramName), value);
            }
        }
    }

    
    /** 
     * Get the ProbeSuite this TemplateProbe is a member of
     * @return ProbeSuite instance
     */
    public ProbeSuite getProbeSuite() {
        if (getProbeSuites() == null) {
            return null;
        }
        else {
            return (ProbeSuite) getProbeSuites().iterator().next();
        }
    }
    
    /**
     * Set the probe suite to which this probe belongs
     * @param ps the new parent probe suite
     * @param user the user setting the suite
     */
    public void setProbeSuite(ProbeSuite ps, User user) {
        ProbeSuite old = getProbeSuite();
        if (old != null && old.getProbes().contains(this)) {
            old.removeProbe(this);
        }
        if (getProbeSuites() == null) {
            setProbeSuites(new HashSet());
        }
        getProbeSuites().add(ps);
        if (!ps.getProbes().contains(this)) {
            ps.addProbe(this, user);
        }
        assert getProbeSuites().size() == 1;
    }
    
    /**
     * Returns current ProbeType
     * @return ProbeType
     */
    public ProbeType getType() {
        synchronized (this) {
            if (this.type == null) {
                setType(MonitoringConstants.getProbeTypeSuite());
            }
        }
        return this.type;
    }
    
    /**
     * @return Returns the probeSuites.
     */
    private Set getProbeSuites() {
        return probeSuites;
    }

    
    /**
     * @param probeSuitesIn The probeSuites to set.
     */
    private void setProbeSuites(Set probeSuitesIn) {
        this.probeSuites = probeSuitesIn;
    }
    
}
