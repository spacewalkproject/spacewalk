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
package com.redhat.rhn.frontend.xmlrpc.kickstart.tree;


import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartInstallType;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.kickstart.KickstartableTreeDetail;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.kickstart.tree.TreeCreateOperation;
import com.redhat.rhn.manager.kickstart.tree.TreeDeleteOperation;
import com.redhat.rhn.manager.kickstart.tree.TreeEditOperation;

import java.util.List;

/**
 * KickstartTreeHandler - methods related to CRUD operations
 * on KickstartableTree objects.
 * @xmlrpc.namespace kickstart.tree
 * @xmlrpc.doc Provides methods to access and modify the kickstart trees.
 * @version $Rev$
 */
public class KickstartTreeHandler extends BaseHandler {

    /**
     * Returns details of kickstartable tree specified by the label
     * @param sessionKey User's session key.
     * @param treeLabel Label of kickstartable tree to search.
     * @return found KickstartableTreeObject
     *
     * @xmlrpc.doc The detailed information about a kickstartable tree given the tree name.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "treeLabel", "Label of kickstartable tree to
     * search.")
     * @xmlrpc.returntype $KickstartTreeDetailSerializer
     */
    public KickstartableTreeDetail getDetails(String sessionKey, String treeLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);
        ensureConfigAdmin(loggedInUser);

        KickstartableTree tree = KickstartFactory.lookupKickstartTreeByLabel(treeLabel);
        if (tree == null) {
            throw new InvalidChannelLabelException();
        }

        return new KickstartableTreeDetail(tree);
    }

    /**
     * List the available kickstartable trees for the given channel.
     * @param sessionKey User's session key.
     * @param channelLabel Label of channel to search.
     * @return Array of KickstartableTreeObjects
     *
     * @xmlrpc.doc List the available kickstartable trees for the given channel.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "channelLabel", "Label of channel to
     * search.")
     * @xmlrpc.returntype #array() $KickstartTreeSerializer #array_end()
     */
    public List list(String sessionKey,
            String channelLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);
        ensureConfigAdmin(loggedInUser);

        List<KickstartableTree> ksTrees = KickstartFactory
                .lookupKickstartableTrees(
                        getChannel(channelLabel, loggedInUser).getId(),
                            loggedInUser.getOrg());
        return ksTrees;
    }

    /**
     * List the available kickstartable tree types (rhel2,3,4,5 and fedora9+)
     * @param sessionKey User's session key.
     * @return Array of KickstartInstallType objects
     *
     * @xmlrpc.doc List the available kickstartable install types (rhel2,3,4,5 and
     * fedora9+).
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype #array() $KickstartInstallTypeSerializer #array_end()
     */
    public List listInstallTypes(String sessionKey) {
        return KickstartFactory.lookupKickstartInstallTypes();
    }

    /**
     * Create a Kickstart Tree (Distribution) in Satellite
     *
     * @param sessionKey User's session key.
     * @param treeLabel Label for the new kickstart tree
     * @param basePath path to the base/root of the kickstart tree.
     * @param channelLabel label of channel to associate with ks tree.
     * @param installType String label for KickstartInstallType (rhel_2.1,
     * rhel_3, rhel_4, rhel_5, fedora_9)
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Create a Kickstart Tree (Distribution) in Satellite.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "treeLabel" "The new kickstart tree label.")
     * @xmlrpc.param #param_desc("string", "basePath", "Path to the base or
     * root of the kickstart tree.")
     * @xmlrpc.param #param_desc("string", "channelLabel", "Label of channel to
     * associate with the kickstart tree. ")
     * @xmlrpc.param #param_desc("string", "installType", "Label for
     * KickstartInstallType (rhel_2.1, rhel_3, rhel_4, rhel_5, fedora_9).")
     * @xmlrpc.returntype #return_int_success()
     */
    public int create(String sessionKey, String treeLabel,
            String basePath, String channelLabel,
            String installType) {

        User loggedInUser = getLoggedInUser(sessionKey);
        ensureConfigAdmin(loggedInUser);

        TreeCreateOperation create = new TreeCreateOperation(loggedInUser);
        create.setBasePath(basePath);
        create.setChannel(getChannel(channelLabel, loggedInUser));
        create.setInstallType(getInstallType(installType));
        create.setLabel(treeLabel);
        ValidatorError ve = create.store();
        if (ve != null) {
            throw new InvalidKickstartTreeException(ve.getKey());
        }
        return 1;
    }


    /**
     * Delete a kickstarttree
     * kickstartable tree and kickstart host specified.
     *
     * @param sessionKey User's session key.
     * @param treeLabel Label for the new kickstart tree
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Delete a Kickstart Tree (Distribution) in Satellite.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "treeLabel" "Label for the
     * kickstart tree to delete.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int delete(String sessionKey, String treeLabel) {

        User loggedInUser = getLoggedInUser(sessionKey);
        ensureConfigAdmin(loggedInUser);

        TreeDeleteOperation op = new TreeDeleteOperation(treeLabel, loggedInUser);
        if (op.getTree() == null) {
            throw new InvalidKickstartTreeException("api.kickstart.tree.notfound");
        }
        ValidatorError ve = op.store();
        if (ve != null) {
            throw new InvalidKickstartTreeException(ve.getKey());
        }
        return 1;
    }

    /**
     * Delete a kickstarttree and any profiles associated with this kickstart tree.
     * WARNING:  This will delete all profiles associated with this kickstart tree!
     *
     * @param sessionKey User's session key.
     * @param treeLabel Label for the new kickstart tree
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Delete a kickstarttree and any profiles associated with
     * this kickstart tree.  WARNING:  This will delete all profiles
     * associated with this kickstart tree!
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "treeLabel" "Label for the
     * kickstart tree to delete.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int deleteTreeAndProfiles(String sessionKey, String treeLabel) {

        User loggedInUser = getLoggedInUser(sessionKey);
        ensureConfigAdmin(loggedInUser);

        TreeDeleteOperation op = new TreeDeleteOperation(treeLabel, loggedInUser);
        if (op.getTree() == null) {
            throw new InvalidKickstartTreeException("api.kickstart.tree.notfound");
        }
        op.setDeleteProfiles(Boolean.TRUE);
        ValidatorError ve = op.store();
        if (ve != null) {
            throw new InvalidKickstartTreeException(ve.getKey());
        }
        return 1;
    }

    /**
     * Edit a kickstarttree.  This method will not edit the label of the tree, see
     * renameTree().
     *
     * @param sessionKey User's session key.
     * @param treeLabel Label for the existing kickstart tree
     * @param basePath New basepath for tree.
     * rhn-kickstart.
     * @param channelLabel New channel label to lookup and assign to
     * the kickstart tree.
     * @param installType String label for KickstartInstallType (rhel_2.1,
     * rhel_3, rhel_4, rhel_5, fedora_9)
     *
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Edit a Kickstart Tree (Distribution) in Satellite.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "treeLabel" "Label for the kickstart tree.")
     * @xmlrpc.param #param_desc("string", "basePath", "Path to the base or
     * root of the kickstart tree.")
     * @xmlrpc.param #param_desc("string", "channelLabel", "Label of channel to
     * associate with kickstart tree.")
     * @xmlrpc.param #param_desc("string", "installType", "Label for
     * KickstartInstallType (rhel_2.1, rhel_3, rhel_4, rhel_5, fedora_9).")
     *
     * @xmlrpc.returntype #return_int_success()
     */
    public int update(String sessionKey, String treeLabel, String basePath,
                 String channelLabel, String installType) {


        User loggedInUser = getLoggedInUser(sessionKey);
        ensureConfigAdmin(loggedInUser);

        TreeEditOperation op = new TreeEditOperation(treeLabel, loggedInUser);
        if (op.getTree() == null) {
            throw new InvalidKickstartTreeException("api.kickstart.tree.notfound");
        }
        op.setBasePath(basePath);
        op.setChannel(getChannel(channelLabel, loggedInUser));
        op.setInstallType(getInstallType(installType));

        ValidatorError ve = op.store();
        if (ve != null) {
            throw new InvalidKickstartTreeException(ve.getKey());
        }
        return 1;
    }

    /**
     * Rename a kickstart tree.
     *
     * @param sessionKey User's session key.
     * @param originalLabel Label for tree we want to edit
     * @param newLabel to assign to tree.
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Rename a Kickstart Tree (Distribution) in Satellite.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "originalLabel" "Label for the
     * kickstart tree to rename.")
     * @xmlrpc.param #param_desc("string", "newLabel" "The kickstart tree's new label.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int rename(String sessionKey, String originalLabel, String newLabel) {

        User loggedInUser = getLoggedInUser(sessionKey);
        ensureConfigAdmin(loggedInUser);

        TreeEditOperation op = new TreeEditOperation(originalLabel, loggedInUser);

        if (op.getTree() == null) {
            throw new InvalidKickstartTreeException("api.kickstart.tree.notfound");
        }
        op.setLabel(newLabel);
        ValidatorError ve = op.store();
        if (ve != null) {
            throw new InvalidKickstartTreeException(ve.getKey());
        }
        return 1;
    }

    private Channel getChannel(String label, User user) {
        Channel channel = ChannelManager.lookupByLabelAndUser(label,
                user);
        if (channel == null) {
            throw new InvalidChannelLabelException();
        }
        return channel;
    }

    private KickstartInstallType getInstallType(String installType) {
        KickstartInstallType type =
            KickstartFactory.lookupKickstartInstallTypeByLabel(installType);
        if (type == null) {
            throw new NoSuchKickstartInstallTypeException(installType);
        }
        return type;

    }

}
