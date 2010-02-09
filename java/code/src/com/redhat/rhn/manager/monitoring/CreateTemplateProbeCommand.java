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
import com.redhat.rhn.domain.monitoring.TemplateProbe;
import com.redhat.rhn.domain.monitoring.command.Command;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.user.User;

/**
 * Command to create and then modify a template probe
 * @version $Rev$
 */
public class CreateTemplateProbeCommand extends ModifyProbeCommand {

    private ProbeSuite suite;

    /**
     * Create a command that modifies a new probe. The probe is created for
     * <code>command</code> and attached to the suite <code>suite</code>
     * @param userIn the user creating the probe
     * @param command the command underlying the probe
     * @param suite0 the suite to which the probe should be attached
     */
    public CreateTemplateProbeCommand(User userIn, Command command, ProbeSuite suite0) {
        super(userIn, command, TemplateProbe.newInstance());
        Asserts.assertNotNull(suite0, "suite0");
        suite = suite0;
    }

    /**
     * {@inheritDoc}
     */
    public void storeProbe() {
        TemplateProbe mine = (TemplateProbe) getProbe();
        suite.addProbe(mine, getUser());
        super.storeProbe();
    }


}
