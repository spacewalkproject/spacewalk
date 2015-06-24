/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.user.User;


/**
 * CobblerProfileComand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public class CobblerDistroCommand extends CobblerCommand {

    protected KickstartableTree tree;

    /**
     * @param userIn - user wanting to sync with cobbler
     */
    public CobblerDistroCommand(User userIn) {
        super(userIn);
    }

    /**
     * @param ksTreeIn - KickstartableTree to sync
     * @param userIn - user wanting to sync with cobbler
     */
    public CobblerDistroCommand(KickstartableTree ksTreeIn, User userIn) {
        super(userIn);
        this.tree = ksTreeIn;
    }

    /**
     * @param ksTreeIn - KickstartableTree to sync
     */
    public CobblerDistroCommand(KickstartableTree ksTreeIn) {
        super();
        this.tree = ksTreeIn;
    }

    /**
     * {@inheritDoc}
     */
    public ValidatorError store() {
        throw new UnsupportedOperationException();
    }

}
