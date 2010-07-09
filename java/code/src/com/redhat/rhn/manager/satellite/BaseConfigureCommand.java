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

import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;

/**
 * BaseConfigureCommand - abstract class to contain some logic for
 * configuring a Spacewalk.
 * @version $Rev$
 */
public abstract class BaseConfigureCommand {

    private User user;

    /**
     * Create a new ConfigureSatelliteCommand class with the
     * user requesting the config.
     * @param userIn who wants to config the sat.
     */
    public BaseConfigureCommand(User userIn) {
        this.user = userIn;

        if (!this.user.hasRole(RoleFactory.SAT_ADMIN)) {
            throw new IllegalArgumentException("Must be SAT_ADMIN" +
                    "to use this Command");
        }

    }

    /**
     * @return Returns the user.
     */
    public User getUser() {
        return this.user;
    }

    /**
     * Create an instance of the Executor class to actually
     * call out to the system to update the Config.
     * @return Executor instance.
     */
    protected Executor getExecutor() {
        return new SystemCommandExecutor();
    }

}
