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
package com.redhat.rhn.domain.monitoring.command.test;

import com.redhat.rhn.domain.monitoring.MonitoringFactory;
import com.redhat.rhn.domain.monitoring.command.Command;
import com.redhat.rhn.domain.monitoring.command.CommandGroup;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.List;

public class CommandGroupTest extends RhnBaseTestCase {

    public void testContains() {
        List groups = MonitoringFactory.loadAllCommandGroups();
        CommandGroup g1 = (CommandGroup) groups.get(0);
        CommandGroup g2 = (CommandGroup) groups.get(1);
        Command c1 = (Command) g1.getCommands().iterator().next();
        assertTrue(g1.contains(c1));
        assertFalse(g2.contains(c1));
    }

    public void testAllContainsEverything() {
        List commands = MonitoringFactory.loadAllCommands();
        CommandGroup all = MonitoringFactory
                .lookupCommandGroup(CommandGroup.ALL_GROUP_NAME);
        for (int i = 0; i < commands.size(); i++) {
            Command c = (Command) commands.get(i);
            assertTrue(all.contains(c));
        }
    }
}
