/**
 * Copyright (c) 2008 Red Hat, Inc.
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
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchChannelException;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.kickstart.tree.TreeCreateOperation;

import java.util.List;

/**
 * KickstartTreeHandler - methods related to CRUD operations
 * on KickstartableTree objects.
 * @xmlrpc.namespace kickstart
 * @xmlrpc.doc Provides methods to create kickstart files
 * @version $Rev$
 */
public class KickstartTreeHandler extends BaseHandler {

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
    public Object[] listKickstartableTrees(String sessionKey,
            String channelLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Channel channel = ChannelManager.lookupByLabelAndUser(channelLabel,
                loggedInUser);
        if (channel == null) {
            throw new InvalidChannelLabelException();
        }
        List<KickstartableTree> ksTrees = KickstartFactory
                .lookupKickstartableTrees(channel.getId(), loggedInUser
                        .getOrg());
        return ksTrees.toArray();
    }

    
    /**
     * Create a new kickstart profile using the default download URL for the
     * kickstartable tree and kickstart host specified.
     * 
     * @param sessionKey User's session key.
     * @param treeLabel Label for the new kickstart tree
     * @param basePath path to the base/root of the kickstart tree.
     * @param bootImage name of boot image to use
     * @param channelLabel label of channel to associate with ks tree. 
     * @param installType String label for KickstartInstallType (rhel_2.1, 
     * rhel_3, rhel_4, rhel_5, fedora_9)
     * @return 1 if successful, exception otherwise.
     * 
     * @xmlrpc.doc Create a Kickstart Tree (Distribution) in Satellite
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "treeLabel" "Label for the new kickstart tree")
     * @xmlrpc.param #param_desc("string", "basePath", "path to the base/
     * root of the kickstart tree.")
     * @xmlrpc.param #param_desc("string", "bootImage", "name of boot image to use")
     * @xmlrpc.param #param_desc("string", "channelLabel", "label of channel to 
     * associate with ks tree. ")
     * @xmlrpc.param #param_desc("string", "installType", "String label for 
     * KickstartInstallType (rhel_2.1, rhel_3, rhel_4, rhel_5, fedora_9")
     * @xmlrpc.returntype #return_int_success()
     */
    public int createTree(String sessionKey, String treeLabel,
            String basePath, String bootImage, String channelLabel,
            String installType) {

        User loggedInUser = getLoggedInUser(sessionKey);
        Channel channel = ChannelManager.lookupByLabel(loggedInUser.getOrg(), channelLabel);
        if (channel == null) {
            throw new NoSuchChannelException();
        }
        KickstartInstallType type = 
            KickstartFactory.lookupKickstartInstallTypeByLabel(installType);
        if (channel == null) {
            throw new NoSuchKickstartInstallTypeException(installType);
        }

        
        TreeCreateOperation create = new TreeCreateOperation(loggedInUser);
        create.setBasePath(basePath);
        create.setBootImage(bootImage);
        create.setChannel(channel);
        create.setInstallType(type);
        create.setLabel(treeLabel);
        ValidatorError ve = create.store();
        if (ve != null) {
            throw new InvalidKickstartTreeException(ve.getKey());
        }
        return 1;
    }


    
}
