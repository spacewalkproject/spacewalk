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
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.ProbeParameterValue;
import com.redhat.rhn.domain.monitoring.command.Command;
import com.redhat.rhn.domain.monitoring.command.CommandParameter;
import com.redhat.rhn.domain.monitoring.command.Metric;
import com.redhat.rhn.domain.monitoring.notification.ContactGroup;
import com.redhat.rhn.domain.user.User;

import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;

/**
 * A command to create or edit a probe. Use the setters to modify the probe.
 * After all modifications are made, call {@link #storeProbe} to save the probe.
 * @version $Rev$
 */
public class ModifyProbeCommand {

    public static final Long NOTIF_INTERVAL_DEFAULT = new Long(5);
    public static final Long CHECK_INTERVAL_DEFAULT = new Long(5);
    public static final String COMMAND_GROUP_DEFAULT = "linux";
    public static final String COMMAND_DEFAULT = "remote_check_load";

    private Probe probe;
    private User  user;
    private Date  now;

    /**
     * Create a command that modifies an existing probe. The probe with
     * the given <code>probeid</code> is loaded from the database.
     *
     * @param userIn the user editing the probe
     * @param probe0 the probe to modify
     */
    public ModifyProbeCommand(User userIn, Probe probe0) {
        Asserts.assertNotNull(probe0, "probe0");
        init(userIn);
        probe = probe0;
    }

    /**
     * Create a command that modifies a new probe. The probe is created for
     * <code>command</code>.
     *
     * @param userIn the user creating the probe
     * @param command the command underlying the probe
     * @param probe0 the empty, freshly created probe
     */
    protected ModifyProbeCommand(User userIn, Command command, Probe probe0) {
        Asserts.assertNotNull(command, "command");
        init(userIn);
        initProbe(command, probe0);
    }

    /**
     * Return the probe that is being modified by this command
     * @return the probe being modified by this command
     */
    public Probe getProbe() {
        return probe;
    }

    /**
     * Set the description of the probe
     * @param descr the description for the probe
     */
    public void setDescription(String descr) {
        probe.setDescription(descr);
    }

    /**
     * Turn notification for the probe on or off.
     * @param notif whether notification should be turned on or off
     */
    public void setNotification(Boolean notif) {
        probe.setNotifyCritical(notif);
        probe.setNotifyRecovery(notif);
        probe.setNotifyUnknown(notif);
        probe.setNotifyWarning(notif);
    }

    /**
     * Set the check interval for the probe
     * @param intv the new check interval
     */
    public void setCheckIntervalMinutes(Long intv) {
        probe.setCheckIntervalMinutes(intv);
    }

    /**
     * Set the notification interval of the probe
     * @param intv the new notification interval
     */
    public void setNotificationIntervalMinutes(Long intv) {
        if (intv != null) {
            probe.setNotificationIntervalMinutes(intv);
        }
    }

    /**
     * Set the contact group
     * @param groupID  The ID of the contact group
     */
    public void setContactGroup(Long groupID) {
        if (groupID != null) {
            Iterator i = user.getOrg().getContactGroups().iterator();
            while (i.hasNext()) {
                ContactGroup cg = (ContactGroup) i.next();
                if (cg.getId().equals(groupID)) {
                    probe.setContactGroup(cg);
                }
            }
        }
    }

    /**
     * Set the value for parameter <code>cp</code> to <code>value</code>
     * in the underlying probe.
     *
     * @param cp the command parameter
     * @param value the new value for the parameter in the probe we are modifying
     */
    public void setParameterValue(CommandParameter cp, String value) {
        Asserts.assertNotNull(cp, "cp");
        Asserts.assertEquals(cp.getCommand().getName(), probe.getCommand().getName());
        if (!cp.getValidator().isValid(value)) {
            throw new IllegalArgumentException("The value " + value +
                    " is not valid for " + cp.getParamName());
        }
        ProbeParameterValue ppv = probe.getProbeParameterValue(cp);
        probe.setParameterValue(ppv, value);
        ppv.setLastUpdateDate(now);
        ppv.setLastUpdateUser(user.getLogin());
    }

    /**
     * Store the probe to the database
     */
    public void storeProbe() {
        for (Iterator i = commandParametersIter(); i.hasNext();) {
            CommandParameter cp = (CommandParameter) i.next();
            String value = probe.getProbeParameterValue(cp).getValue();
            if (!cp.getValidator().isValid(value)) {
                throw new IllegalStateException("The value " + value +
                        " is not valid for " + cp.getParamName());
            }
        }
        Command c = probe.getCommand();
        for (Iterator i = c.getMetrics().iterator(); i.hasNext();) {
            Metric m = (Metric) i.next();
            ArrayList errors = c.checkAscendingValues(m, probe.toValue());
            if (!errors.isEmpty()) {
                throw new IllegalStateException("The values for metric " +
                        m.getDescription() + " are not in increasing order");
            }
        }
        MonitoringManager.getInstance().storeProbe(probe, user);
    }

    /**
     * Return an iterator over the command parameters of the probe's command;
     * the elements in the iterator are of type {@link CommandParameter}.
     * @return an iterator over the command parameters of the probe's command
     */
    public Iterator commandParametersIter() {
        return probe.getCommand().getCommandParameters().iterator();
    }

    /**
     * Return the command underlying the probe being constructed
     * @return the command underlying the probe being constructed
     */
    public Command getCommand() {
        return probe.getCommand();
    }


    /**
     * @return Returns the user.
     */
    protected User getUser() {
        return user;
    }

    private void init(User userIn) {
        Asserts.assertNotNull(userIn, "userIn");
        user = userIn;
        now = new Date();
    }

    private void initProbe(Command command, Probe probe0) {
        assert user != null;
        assert command != null;
        assert probe0 != null;

        probe = probe0;

        probe.setOrg(user.getOrg());
        probe.setCommand(command);

        probe.setLastUpdateDate(now);
        probe.setLastUpdateUser(user.getLogin());
        probe.setRetryIntervalMinutes(CHECK_INTERVAL_DEFAULT);
        setNotificationIntervalMinutes(NOTIF_INTERVAL_DEFAULT);
        // Create parameter values
        for (Iterator i = commandParametersIter(); i.hasNext();) {
            CommandParameter cp = (CommandParameter) i.next();
            probe.addProbeParameterValue(cp.getDefaultValue(), cp, user);
        }
    }

}
