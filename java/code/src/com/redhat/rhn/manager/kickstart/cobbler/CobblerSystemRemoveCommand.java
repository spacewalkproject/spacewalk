/**
 * Copyright (c) 2011 Red Hat, Inc.
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
package com.redhat.rhn.manager.kickstart.cobbler;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;

import org.cobbler.SystemRecord;

/**
 * @version $Rev$
 */
public class CobblerSystemRemoveCommand extends CobblerCommand {

    private Server server;

    /**
     * Constructor
     * @param userIn who is requesting the sync
     * @param serverIn profile we want to delete in cobbler
     */
    public CobblerSystemRemoveCommand(User userIn, Server serverIn) {
        super(userIn);
        this.server = serverIn;
    }

    /**
     * Remove the System from cobbler
     * @return ValidatorError if the remoev failed.
     */
    public ValidatorError store() {
        String cobblerId = server.getCobblerId();
        SystemRecord sr = null;

        if (cobblerId != null) {
            sr = SystemRecord.lookupById(CobblerXMLRPCHelper.getConnection(user),
                cobblerId);
        }

        if (sr != null) {
            sr.remove();
        }

        return null;
    }
}
