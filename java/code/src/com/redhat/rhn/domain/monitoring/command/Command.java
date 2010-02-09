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
package com.redhat.rhn.domain.monitoring.command;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.collections.Predicate;
import org.apache.commons.collections.Transformer;
import org.apache.commons.lang.math.NumberUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * Command - Class representation of the table rhn_command.
 * @version $Rev: 1 $
 */
public class Command {

    private Long id;
    private String name;
    private String description;
    private boolean allowedInSuite;
    private boolean enabled;
    private boolean forHostProbe;
    private String lastUpdateUser;
    private Date lastUpdateDate;
    private String systemRequirements;
    private String versionSupport;
    private String helpUrl;

    private CommandGroup commandGroup;
    private CommandClass commandClass;
    private Set commandParameters;

    /**
     * Getter for id
     * @return Long to get
     */
    public Long getId() {
        return this.id;
    }

    /**
     * Setter for id
     * @param idIn to set
     */
    private void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Getter for name
     * @return String to get
     */
    public String getName() {
        return this.name;
    }

    /**
     * Setter for name
     * @param nameIn to set
     */
    private void setName(String nameIn) {
        this.name = nameIn;
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
    private void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }

    /**
     * Getter for allowedInSuite
     * @return String to get
     */
    public boolean isAllowedInSuite() {
        return this.allowedInSuite;
    }

    /**
     * Setter for allowedInSuite
     * @param allowedInSuiteIn to set
     */
    private void setAllowedInSuite(boolean allowedInSuiteIn) {
        this.allowedInSuite = allowedInSuiteIn;
    }

    /**
     * Return <code>true</code> if this command is enabled
     * @return <code>true</code> if this command is enabled
     */
    public boolean isEnabled() {
        // TODO Fix mapping for enabled to be boolean
        return enabled;
    }

    /**
     * Setter for enabled
     * @param enabledIn to set
     */
    private void setEnabled(boolean enabledIn) {
        this.enabled = enabledIn;
    }

    /**
     * Getter for forHostProbe
     * @return String to get
     */
    public boolean isForHostProbe() {
        return this.forHostProbe;
    }

    /**
     * Setter for forHostProbe
     * @param forHostProbeIn to set
     */
    private void setForHostProbe(boolean forHostProbeIn) {
        this.forHostProbe = forHostProbeIn;
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
    private void setLastUpdateUser(String lastUpdateUserIn) {
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
    private void setLastUpdateDate(Date lastUpdateDateIn) {
        this.lastUpdateDate = lastUpdateDateIn;
    }

    /**
     * Getter for systemRequirements
     * @return String to get
     */
    public String getSystemRequirements() {
        return this.systemRequirements;
    }

    /**
     * Setter for systemRequirements
     * @param systemRequirementsIn to set
     */
    private void setSystemRequirements(String systemRequirementsIn) {
        this.systemRequirements = systemRequirementsIn;
    }

    /**
     * Getter for versionSupport
     * @return String to get
     */
    public String getVersionSupport() {
        return this.versionSupport;
    }

    /**
     * Setter for versionSupport
     * @param versionSupportIn to set
     */
    private void setVersionSupport(String versionSupportIn) {
        this.versionSupport = versionSupportIn;
    }

    /**
     * Getter for helpUrl
     * @return String to get
     */
    public String getHelpUrl() {
        return this.helpUrl;
    }

    /**
     * Setter for helpUrl
     * @param helpUrlIn to set
     */
    private void setHelpUrl(String helpUrlIn) {
        this.helpUrl = helpUrlIn;
    }

    /**
     * @return Returns the commandClass.
     */
    public CommandClass getCommandClass() {
        return commandClass;
    }

    /**
     * @param commandClassIn The commandClass to set.
     */
    private void setCommandClass(CommandClass commandClassIn) {
        this.commandClass = commandClassIn;
    }

    /**
     * @return the group this command belongs to
     */
    public CommandGroup getCommandGroup() {
        return commandGroup;
    }

    /**
     * @param commandGroup0 the command group to set
     */
    private void setCommandGroup(CommandGroup commandGroup0) {
        this.commandGroup = commandGroup0;
    }

    /**
     * Convenience accessor method to get the Metrics for a Command
     * @return set of Metric objects associated with this Command
     */
    public Set getMetrics() {
        return this.commandClass.getMetrics();
    }

    /**
     * @return Returns the commandParameters.
     */
    public Set getCommandParameters() {
        return commandParameters;
    }

    /**
     * @param commandParametersIn The commandParameters to set.
     */
    private void setCommandParameters(Set commandParametersIn) {
        this.commandParameters = commandParametersIn;
    }

    /**
     * Return a list of threshold parameters for the metric <code>m</code>.
     * The parameters are sorted by ascendint {@link ThresholdType}.
     * @param m the metric for which to list parameters
     * @return a list of threshold parameters in ascending order
     */
    public List listThresholds(Metric m) {
        ArrayList result = new ArrayList();
        CollectionUtils.select(getCommandParameters(),
                new ParameterForMetric(m), result);
        Collections.sort(result, new ThresholdParameter.ByType());
        return result;
    }

    /**
     * Check that values for a given metric are in monotonically increasing
     * order. For the metric <code>m</code>, look at the associated threshold
     * parameters and ensure that the values returned by <code>toValue</code>
     * for them are in strictly ascending order.
     * <p>
     * Each violation is entered into the returned list as four values: (param1,
     * value1, param2, value2) such that
     * <code>param1.thresholdType &lt; param2.thresholdType</code>, but
     * <code>value1 &gt;= value2</code> when compared as numbers. The
     * parameters in the returned list are of type {@link ThresholdParameter},
     * and the values are strings.
     * 
     * @param metric the metric for which to check the parameter values
     * @param toValue a transformer mapping threshold parameters to their value
     * @return a list indicating which parameters have non-ascending values.
     */
    public ArrayList checkAscendingValues(Metric metric, Transformer toValue) {
        ArrayList result = new ArrayList();
        ThresholdParameter prevParam = null;
        Float prevValue = null;
        String prevStr = null;
        for (Iterator j = listThresholds(metric).iterator(); j.hasNext();) {
            ThresholdParameter currParam = (ThresholdParameter) j.next();
            String currStr = (String) toValue.transform(currParam);
            Float currValue = null;
            try {
                currValue = NumberUtils.createFloat(currStr);
            } 
            catch (NumberFormatException e) {
                // Ignore this value
                currValue = null;
            }
            if (currValue != null && prevValue != null) {
                if (currValue.compareTo(prevValue) <= 0) {
                    result.add(prevParam);
                    result.add(prevStr);
                    result.add(currParam);
                    result.add(currStr);
                }
            }
            if (currValue != null) {
                prevValue = currValue;
                prevParam = currParam;
                prevStr = currStr;
            }
        }
        assert result.size() % 4 == 0;
        return result;
    }

    /**
     * A predicate that matches commands that have the same name as the command
     * passed to the constructor
     */
    public static final class NameEquals implements Predicate {

        private Command c;

        /**
         * Create a new predicate for name equality
         * @param c0 the command to compare to
         */
        public NameEquals(Command c0) {
            c = c0;
        }

        /**
         * {@inheritDoc}
         */
        public boolean evaluate(Object object) {
            return c.getName().equals(((Command) object).getName());
        }

    }

    private static final class ParameterForMetric implements Predicate {

        private Metric m;

        public ParameterForMetric(Metric m0) {
            m = m0;
        }

        public boolean evaluate(Object object) {
            return (object instanceof ThresholdParameter) && 
                m.equals(((ThresholdParameter) object).getMetric());
        }

    }
}
