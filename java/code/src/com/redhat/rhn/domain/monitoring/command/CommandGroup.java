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

import java.util.Set;

/**
 * CommandGroup - Class representation of the table rhn_command_groups.
 * @version $Rev: 1 $
 */
public class CommandGroup {

    /**
     * The name of the <tt>all</tt> pseudo-group. A group with this
     * name exists, but it contains no commands
     */
    public static final String ALL_GROUP_NAME = "all";

    private String groupName;
    private String description;
    private Set commands;

    /**
     * Getter for groupName
     * @return String to get
    */
    public String getGroupName() {
        return this.groupName;
    }

    /**
     * Setter for groupName
     * @param groupNameIn to set
    */
    private void setGroupName(String groupNameIn) {
        this.groupName = groupNameIn;
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
     * @return the commands in this group
     */
    public Set getCommands() {
        return commands;
    }

    private void setCommands(Set commandsIn) {
        commands = commandsIn;
    }

    /**
     * Return <code>true</code> if <code>c</code> is contained in this
     * group. The comparison is based on command names.
     * @param c the command to check for
     * @return <code>true</code> if <code>c</code> is contained in this
     * group
     */
    public boolean contains(Command c) {
        if (ALL_GROUP_NAME.equals(getGroupName())) {
            return true;
        }
        return CollectionUtils.exists(getCommands(), new Command.NameEquals(c));
    }
}
