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
package com.redhat.rhn.frontend.dto;

import com.redhat.rhn.domain.monitoring.command.CommandParameter;

/**
 * Simple DTO to wrap a com.redhat.rhn.domain.monitoring.command.CommandParameter
 * and the value used by the ServerProbe
 *
 * @version $Rev: 50942 $
 */
public class CommandParameterValue {

    private CommandParameter commandParameter;
    private String value;

    /**
     * Create an instance with default values
     * @param paramIn param to use
     * @param valueIn to be used
     */
    public CommandParameterValue(CommandParameter paramIn, String valueIn) {
        super();
        this.commandParameter = paramIn;
        this.value = valueIn;
    }

    /**
     * @return Returns the commandParameter.
     */
    public CommandParameter getCommandParameter() {
        return commandParameter;
    }
    /**
     * @param commandParameterIn The commandParameter to set.
     */
    public void setCommandParameter(CommandParameter commandParameterIn) {
        this.commandParameter = commandParameterIn;
    }

    /**
     * @return Returns the value.
     */
    public String getValue() {
        return value;
    }
    /**
     * @param valueIn The value to set.
     */
    public void setValue(String valueIn) {
        this.value = valueIn;
    }
}
