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
package com.redhat.rhn.manager.satellite;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.user.User;

import java.util.LinkedList;
import java.util.List;

/**
 * RestartCommand - simple Command class to restart a Sat.  User must
 * be ORG_ADMIN to use this Command.
 * @version $Rev$
 */
public class RestartCommand extends BaseConfigureCommand
    implements SatelliteConfigurator {

    /**
     * Construct the Command
     * @param userIn who wants to restart
     */
    public RestartCommand(User userIn) {
        super(userIn);
    }

    /**
     * {@inheritDoc}
     */
    public ValidatorError[] storeConfiguration() {
        Executor e = getExecutor();
        ValidatorError[] errors = new ValidatorError[1];
        List args = new LinkedList();
        args.add("/usr/bin/sudo");
        args.add("/usr/sbin/rhn-sat-restart-silent");

        int exitcode = e.execute((String[]) args.toArray(new String[0]));
        if (exitcode != 0) {
            errors[0] = new ValidatorError("restart.config.error");
            return errors;
        }
        else {
            return null;
        }
    }

}
