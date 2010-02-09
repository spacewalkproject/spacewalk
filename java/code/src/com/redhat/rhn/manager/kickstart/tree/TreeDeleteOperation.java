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

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.KickstartDeleteCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerDistroDeleteCommand;

import java.util.List;

/**
 * TreeDeleteOperation to delete a KickstartableTree
 * @version $Rev$
 */
public class TreeDeleteOperation extends BaseTreeEditOperation {

    private Boolean deleteProfiles = Boolean.FALSE;

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
     * Set the delete profiles flag.  If set, invoking store will delete
     * any profile that are currently associated with the tree.
     * 
     * @param deleteProfilesIn flag indicating if profiles associated with
     * the tree should be deleted during store()
     */
    public void setDeleteProfiles(Boolean deleteProfilesIn) {
        deleteProfiles = deleteProfilesIn;
    }
    
    /**
     * {@inheritDoc}
     * store() here actually does a remove operation. 
     * It is done to reuse code from BaseTreeEditOperation and BaseTreeAction
     */
    public ValidatorError store() {

        ValidatorError error = null;
        List<KickstartData> profiles = KickstartFactory.lookupKickstartDatasByTree(
            this.tree);

        if (profiles != null && profiles.size() > 0) {

            if (deleteProfiles) {
                for (KickstartData profile : profiles) {
                    KickstartDeleteCommand cmd = new KickstartDeleteCommand(
                        profile.getId(), this.user);
                    cmd.store();
                }
            }
            else {
                error = new ValidatorError("kickstart.tree.inuse");
            }
        }

        if (error == null) {
            KickstartFactory.removeKickstartableTree(this.tree);
            CobblerDistroDeleteCommand delcmd = new CobblerDistroDeleteCommand(this.tree, 
                this.user);
            delcmd.store();
        }
        return error;
    }


    /**
     * {@inheritDoc}
     */
    protected CobblerCommand getCobblerCommand() {
        return new CobblerDistroDeleteCommand(this.tree, this.user);
    }

}
