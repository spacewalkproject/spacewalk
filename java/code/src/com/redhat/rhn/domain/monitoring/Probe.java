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

import com.redhat.rhn.common.util.Asserts;
import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.domain.monitoring.command.Command;
import com.redhat.rhn.domain.monitoring.command.CommandParameter;
import com.redhat.rhn.domain.monitoring.notification.ContactGroup;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.collections.Transformer;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

/**
 * Probe - Class representation of the table rhn_probe.
 * @version $Rev: 1 $
 */
public abstract class Probe implements Identifiable, Comparable {

    private Long id;
    
    private String description;
    private Boolean notifyCritical;
    private Boolean notifyWarning;
    private Boolean notifyUnknown;
    private Boolean notifyRecovery;
    private Long notificationIntervalMinutes;
    private Long checkIntervalMinutes;
    private Long retryIntervalMinutes;
    private Long maxAttempts;
    private String lastUpdateUser;
    private Date lastUpdateDate;
    
    protected ProbeType type;
    private Org org;
    private Command command;
    private ProbeState state;
    private ContactGroup contactGroup;

    
    private Set probeParameterValues;
        
    protected Probe() {
        
    }
    
    protected Probe(ProbeType type0) {
        setType(type0);
    }
    
    /** 
     * Getter for id 
     * @return Long to get
    */
    public Long getId() {
        return this.id;
    }

    /** 
     * Setter for id 
     * @param recidIn to set
    */
    public void setId(Long recidIn) {
        this.id = recidIn;
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
     * Getter for notifyCritical 
     * @return Boolean to get
    */
    public Boolean getNotifyCritical() {
        return this.notifyCritical;
    }

    /** 
     * Setter for notifyCritical 
     * @param notifyCriticalIn to set
    */
    public void setNotifyCritical(Boolean notifyCriticalIn) {
        this.notifyCritical = notifyCriticalIn;
    }

    /** 
     * Getter for notifyWarning 
     * @return Boolean to get
    */
    public Boolean getNotifyWarning() {
        return this.notifyWarning;
    }

    /** 
     * Setter for notifyWarning 
     * @param notifyWarningIn to set
    */
    public void setNotifyWarning(Boolean notifyWarningIn) {
        this.notifyWarning = notifyWarningIn;
    }

    /** 
     * Getter for notifyUnknown 
     * @return Boolean to get
    */
    public Boolean getNotifyUnknown() {
        return this.notifyUnknown;
    }

    /** 
     * Setter for notifyUnknown 
     * @param notifyUnknownIn to set
    */
    public void setNotifyUnknown(Boolean notifyUnknownIn) {
        this.notifyUnknown = notifyUnknownIn;
    }

    /** 
     * Getter for notifyRecovery 
     * @return Boolean to get
    */
    public Boolean getNotifyRecovery() {
        return this.notifyRecovery;
    }

    /** 
     * Setter for notifyRecovery 
     * @param notifyRecoveryIn to set
    */
    public void setNotifyRecovery(Boolean notifyRecoveryIn) {
        this.notifyRecovery = notifyRecoveryIn;
    }

    /** 
     * Getter for notificationIntervalMinutes 
     * @return Long to get
    */
    public Long getNotificationIntervalMinutes() {
        return this.notificationIntervalMinutes;
    }

    /** 
     * Setter for notificationIntervalMinutes 
     * @param notificationIntervalMinutesIn to set
    */
    public void setNotificationIntervalMinutes(Long notificationIntervalMinutesIn) {
        this.notificationIntervalMinutes = notificationIntervalMinutesIn;
    }

    /** 
     * Getter for checkIntervalMinutes 
     * @return Long to get
    */
    public Long getCheckIntervalMinutes() {
        return this.checkIntervalMinutes;
    }

    /** 
     * Setter for checkIntervalMinutes 
     * @param checkIntervalMinutesIn to set
    */
    public void setCheckIntervalMinutes(Long checkIntervalMinutesIn) {
        this.checkIntervalMinutes = checkIntervalMinutesIn;
    }

    /** 
     * Getter for retryIntervalMinutes 
     * @return Long to get
    */
    public Long getRetryIntervalMinutes() {
        return this.retryIntervalMinutes;
    }

    /** 
     * Setter for retryIntervalMinutes 
     * @param retryIntervalMinutesIn to set
    */
    public void setRetryIntervalMinutes(Long retryIntervalMinutesIn) {
        this.retryIntervalMinutes = retryIntervalMinutesIn;
    }

    /** 
     * Getter for maxAttempts 
     * @return Long to get
    */
    public Long getMaxAttempts() {
        return this.maxAttempts;
    }

    /** 
     * Setter for maxAttempts 
     * @param maxAttemptsIn to set
    */
    public void setMaxAttempts(Long maxAttemptsIn) {
        this.maxAttempts = maxAttemptsIn;
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
     * @return Returns the type.
     */
    public ProbeType getType() {
        return type;
    }
    /**
     * @param typeIn The type to set.
     */
    protected void setType(ProbeType typeIn) {
        this.type = typeIn;
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
     * @return Returns the command.
     */
    public Command getCommand() {
        return command;
    }
    /**
     * @param commandIn The command to set.
     */
    public void setCommand(Command commandIn) {
        this.command = commandIn;
    }
    /**
     * @return Returns the state.
     */
    public ProbeState getState() {
        return state;
    }
    /**
     * @param stateIn The state to set.
     */
    public void setState(ProbeState stateIn) {
        this.state = stateIn;
    }
    
    /**
     * @return Returns the contactGroup.
     */
    public ContactGroup getContactGroup() {
        return contactGroup;
    }
    /**
     * @param contactGroupIn The contactGroup to set.
     */
    public void setContactGroup(ContactGroup contactGroupIn) {
        this.contactGroup = contactGroupIn;
    }
        
    /**
     * Set of monitoring.command.ProbeParameterValues
     * @return Returns the probeParameterValues.
     */
    public Set getProbeParameterValues() {
        return probeParameterValues;
    }
    /**
     * Set of monitoring.command.ProbeParameterValues
     * @param paramValuesIn The probeParameterValues to set.
     */
    public void setProbeParameterValues(Set paramValuesIn) {
        this.probeParameterValues = paramValuesIn;
    }
    
    /**
     * Add a value to a CommandParameter for this probe.
     * @param value value of the param
     * @param paramIn the param you want to add the value to
     * @param userIn who is adding the value (auditing purposes)
     */
    public void addProbeParameterValue(String value, CommandParameter paramIn, 
            User userIn) {
        if (this.probeParameterValues == null) {
            this.probeParameterValues = new HashSet();
        }
        
        ProbeParameterValue ppv = new ProbeParameterValue();
        ppv.setProbe(this);
        setParameterValue(ppv, value);
        ppv.setParamName(paramIn.getParamName());
        ppv.setCommand(this.getCommand());
        ppv.setLastUpdateDate(new Date());
        ppv.setLastUpdateUser(userIn.getLogin());
        this.probeParameterValues.add(ppv);
        
    }
    
    /**
     * Convenience method to fetch a parameter value class for the passed in
     * CommandParameter. It is an error to pass in a command parameter that
     * does not belong to the probe's underlying command. If no probe parameter
     * value is found, an exception is thrown
     * @param cp CommandParameter we want to find the PPV for.
     * @return ProbeParameterValue found, never <code>null</code>
     */
    public ProbeParameterValue getProbeParameterValue(CommandParameter cp) {
        Asserts.assertNotNull(cp, "cp");
        Asserts.assertEquals(cp.getCommand().getName(), getCommand().getName());
        ProbeParameterValue result = findParameter(cp.getParamName());
        assert result != null : "Could not find a parameter for " + cp.getParamName();
        return result;
    }

    /**
     * Return the parameter value for the parameter with
     * name <code>paramName</code>
     * @param paramName the name of the parameter value to find
     * @return the parameter value with name <code>paramName</code> or
     * <code>null</code> if no such parameter value exists
     */
    protected ProbeParameterValue findParameter(String paramName) {
        if (this.probeParameterValues == null) {
            return null;
        }
        Iterator i = this.probeParameterValues.iterator();
        while (i.hasNext()) {
            ProbeParameterValue ppv = (ProbeParameterValue) i.next();
            if (ppv.getParamName().equals(paramName)) {
                return ppv;
            }
        }
        // Not found
        return null;
    }
    
    /**
     * Convenience method to set this ServerProbe's value for a 
     * specified CommandParameter
     * @param paramIn parameter to lookup value for
     * @param valueIn String value to set
     * 
     */
    public void setCommandParameterValue(CommandParameter paramIn, String valueIn) {
        if (this.probeParameterValues == null) {
            return;
        }
        Iterator i = this.probeParameterValues.iterator();
        while (i.hasNext()) {
            ProbeParameterValue ppv = (ProbeParameterValue) i.next();
            if (ppv.getParamName().equals(paramIn.getParamName())) {
                setParameterValue(ppv, valueIn);
            }
        }
    }

    /**
     * Set the value for the probe parameter <code>ppv</code> to
     * <code>value</code>
     * @param ppv the probe parameter value to change, must not be
     *        <code>null</code>
     * @param value the new parameter value
     */
    public void setParameterValue(ProbeParameterValue ppv, String value) {
        Asserts.assertNotNull(ppv, "ppv");
        ppv.setValue(value);
    }

    /**
     * Copy this probe to a new ServerProbe and make sure its of
     * type CHECK
     * @param cloningUser who is cloning the ServerProbe
     * @return newly cloned ServerProbe 
     */
    public ServerProbe deepCopy(User cloningUser) {
        ServerProbe copied = ServerProbe.newInstance();
        copied.setCheckIntervalMinutes(this.getCheckIntervalMinutes());
        copied.setDescription(this.getDescription());
        copied.setMaxAttempts(this.getMaxAttempts());
        copied.setNotificationIntervalMinutes(this.getNotificationIntervalMinutes());
        copied.setNotifyCritical(this.getNotifyCritical());
        copied.setNotifyRecovery(this.getNotifyRecovery());
        copied.setNotifyUnknown(this.getNotifyUnknown());
        copied.setNotifyWarning(this.getNotifyWarning());
        copied.setRetryIntervalMinutes(this.getRetryIntervalMinutes());
        copied.setId(null);
        copied.setLastUpdateDate(this.getLastUpdateDate());
        copied.setLastUpdateUser(cloningUser.getLogin());
        copied.setOrg(this.getOrg());
        copied.setState(this.getState());
        copied.setContactGroup(this.getContactGroup());
        // copied.setServerProbeClusterAssociations(null);
        copied.setCommand(this.getCommand());

        Iterator i = this.getCommand().getCommandParameters().iterator();
        while (i.hasNext()) {
            CommandParameter cp = (CommandParameter) i.next();
            ProbeParameterValue val = this.getProbeParameterValue(cp);
            copied.addProbeParameterValue(val.getValue(), cp, cloningUser);
        }

        return copied;
    }
    
    /**
     * {@inheritDoc}
     */
    public int compareTo(Object o) {
        Probe other = (Probe) o;
        int result = getDescription().compareTo(other.getDescription());
        // Make order stable for probes with identical description
        if (result == 0) {
            result = getId().compareTo(other.getId());
        }
        return result;
    }

    /**
     * 
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("id", id).toString();
    }

    /**
     * Return a transformer that maps command parameters to their values in this
     * probe.
     * @return a transformer that maps command parameters to their values in this
     * probe.
     */
    public Transformer toValue() {
        return new Transformer() {
            public Object transform(Object input) {
                return getProbeParameterValue(((CommandParameter) input)).getValue();
            }
        };
    }
}
