/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerDistroDeleteCommand;

import java.util.List;

/**
 * TreeEditCommand to edit a KickstartableTree
 * @version $Rev$
 */
public class TreeDeleteOperation extends BaseTreeEditOperation {

    /**
     * Default constructor: DONT USE
     * @param userIn to set
     */
    public TreeDeleteOperation(User userIn) {
        super(userIn);
    }

    /**
     * Constructor for use when deleting an existing KickstartableTree
     * @param treeId to lookup
     * @param userIn who owns the tree
     */
    public TreeDeleteOperation(Long treeId, User userIn) {
        super(userIn);
        this.tree = KickstartFactory.
                    lookupKickstartTreeByIdAndOrg(treeId, userIn.getOrg());
    }
    
    /**
     * Constructor for use when deleting an existing KickstartableTree
     * @param treeLabel to lookup
     * @param userIn who owns the tree
     */
    public TreeDeleteOperation(String treeLabel, User userIn) {
        super(treeLabel, userIn);
    }
    
    /**
     * {@inheritDoc}
     * store() here actually does a remove operation. 
     * It is done to reuse code from BaseTreeEditOperation and BaseTreeAction
     */
    public ValidatorError store() {
        List profiles = KickstartFactory.lookupKickstartDatasByTree(this.tree);
        if (profiles != null && profiles.size() > 0) {
            return new ValidatorError("kickstart.tree.inuse");
        }
        else {
            KickstartFactory.removeKickstartableTree(this.tree);
            CobblerDistroDeleteCommand delcmd = new CobblerDistroDeleteCommand(this.tree, 
                    this.user);
            delcmd.store();
            return null;
        }
    }


    /**
     * {@inheritDoc}
     */
    protected CobblerCommand getCobblerCommand() {
        return new CobblerDistroDeleteCommand(this.tree, this.user);
    }

}
