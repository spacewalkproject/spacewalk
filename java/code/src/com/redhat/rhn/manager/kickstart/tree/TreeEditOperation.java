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
package com.redhat.rhn.manager.kickstart.tree;

import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerDistroCreateCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerDistroEditCommand;

import org.apache.commons.lang.StringUtils;

/**
 * TreeEditCommand to edit a KickstartableTree
 * @version $Rev$
 */
public class TreeEditOperation extends BaseTreeEditOperation {

    /**
     * Default constructor: DONT USE
     * @param userIn to set
     */
    public TreeEditOperation(User userIn) {
        super(userIn);
    }

    /**
     * Constructor for use when editing an existing KickstartableTree
     * @param treeId to lookup
     * @param userIn who owns the tree
     */
    public TreeEditOperation(Long treeId, User userIn) {
        super(userIn);
        this.tree = KickstartFactory.
            lookupKickstartTreeByIdAndOrg(treeId, userIn.getOrg());
    }


    /**
     * Constructor for use when deleting an existing KickstartableTree
     * @param treeLabel to lookup
     * @param userIn who owns the tree
     */
    public TreeEditOperation(String treeLabel, User userIn) {
        super(treeLabel, userIn);
    }


    /**
     * {@inheritDoc}
     */
    protected CobblerCommand getCobblerCommand() {
        if (StringUtils.isBlank(tree.getCobblerId())) {
            return new CobblerDistroCreateCommand(tree, user, true);
        }
        return new CobblerDistroEditCommand(this.tree, this.user);
    }


}
