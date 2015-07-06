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
import org.cobbler.CobblerConnection;
import org.cobbler.Distro;

/**
 * KickstartCobblerCommand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public class CobblerDistroEditCommand extends CobblerDistroCommand {

    /**
     * Constructor
     * @param ksTreeIn to sync
     * @param userIn - user wanting to sync with cobbler
     */
    public CobblerDistroEditCommand(KickstartableTree ksTreeIn,
            User userIn) {
        super(ksTreeIn, userIn);
    }

    /**
     * Constructor - for use with taskomatic
     * @param ksTreeIn to sync
     */
    public CobblerDistroEditCommand(KickstartableTree ksTreeIn) {
        super(ksTreeIn);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public ValidatorError store() {
        CobblerConnection con = getCobblerConnection();
        Distro nonXen = Distro.lookupById(con, tree.getCobblerId());
        Distro xen = Distro.lookupById(con, tree.getCobblerXenId());

        //if the newly edited tree does para virt....
        if (tree.doesParaVirt()) {
            //IT does paravirt so we need to either update the xen distro or create one
            if (xen == null) {
                CobblerDistroHelper.getInstance().createXenDistroFromTree(con, tree);
            }
            else {
                CobblerDistroHelper.getInstance().updateXenDistroFromTree(xen, tree);
            }
        }
        else {
            //it doesn't do paravirt, so we need to delete the xen distro
            if (xen != null) {
                xen.remove();
                tree.setCobblerXenId(null);
            }
        }

        if (nonXen != null) {
            CobblerDistroHelper.getInstance().updateDistroFromTree(nonXen, tree);
        }

        return null;
    }

}
