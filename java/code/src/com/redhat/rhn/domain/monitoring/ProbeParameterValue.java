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

import com.redhat.rhn.domain.monitoring.command.Command;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.io.Serializable;
import java.util.Date;

/**
 * ProbeParameterValue - Class representation of the table rhn_probe_param_value.
 * @version $Rev: 1 $
 */
public class ProbeParameterValue implements Serializable {

    private Probe probe;
    private Command command;
    private String paramName;
    private String value;
    private String lastUpdateUser;
    private Date lastUpdateDate;
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
     * @return Returns the probe.
     */
    public Probe getProbe() {
        return probe;
    }
    /**
     * @param probeIn The probe to set.
     */
    public void setProbe(Probe probeIn) {
        this.probe = probeIn;
    }
    /**
     * Getter for paramName
     * @return String to get
    */
    public String getParamName() {
        return this.paramName;
    }

    /**
     * Setter for paramName
     * @param paramNameIn to set
    */
    public void setParamName(String paramNameIn) {
        this.paramName = paramNameIn;
    }

    /**
     * Getter for value
     * @return String to get
    */
    public String getValue() {
        return this.value;
    }

    /**
     * Set the value for this probe parameter. This method should
     * not be called directly; instead, use {@link ServerProbe#setParameterValue}
     * @param valueIn the new parameter value
    */
    protected void setValue(String valueIn) {
        this.value = valueIn;
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
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof ProbeParameterValue)) {
            return false;
        }
        ProbeParameterValue castOther = (ProbeParameterValue) other;
        return new EqualsBuilder().append(probe, castOther.probe).append(
                command, castOther.command).append(paramName,
                castOther.paramName).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(probe).append(command).append(
                paramName).toHashCode();
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
            return new ToStringBuilder(this).append("paramName", paramName).append(
                    "value", value).toString();
        }

}
