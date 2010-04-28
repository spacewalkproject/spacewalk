/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.distchannel;

import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.DistChannelMap;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelArchException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchChannelException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchDistChannelMapException;

/**
 * DistChannelHandler - provides methods to access distribution channel information.
 * @version $Rev$
 * @xmlrpc.namespace distchannel
 * @xmlrpc.doc Provides methods to access and modify distribution channel information
 */
public class DistChannelHandler extends BaseHandler {

    /**
     * Lists the default distribution channel maps defined per satellite
     * @param sessionKey The sessionKey containing the logged in user
     * @return List of dist channel maps
     *
     * @xmlrpc.doc Lists the default distribution channel maps defined per satellite
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     *   #array("dist channel map")
     *      @DistChannelMapSerializer
     *   #array_end()
     */
    public Object[] listDefaultMaps(String sessionKey) {
        return ChannelFactory.listAllDistChannelMaps().toArray();
    }

    /**
     * Sets (/removes if channelLabel empty) a default distribution channel map
     * @param sessionKey The sessionKey containing the logged in user
     * @param os OS
     * @param release Relase
     * @param archLabel architecture label
     * @param channelLabel channel label
     * @return Returns 1 if successful, exception otherwise
     *
     * @xmlrpc.doc Sets (/removes if channelLabel empty) a default distribution channel map
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "os")
     * @xmlrpc.param #param("string", "release")
     * @xmlrpc.param #param("string", "archLabel")
     * @xmlrpc.param #param("string", "channelLabel")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setDefaultMap(String sessionKey, String os, String release,
                                            String archLabel, String channelLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);
        if (!loggedInUser.hasRole(RoleFactory.SAT_ADMIN)) {
            throw new PermissionException(RoleFactory.SAT_ADMIN);
        }

        ChannelArch channelArch = ChannelFactory.lookupArchByName(archLabel);
        if (channelArch == null) {
            throw new InvalidChannelArchException(archLabel);
        }
        DistChannelMap dcm = ChannelFactory.lookupDistChannelMapByOsReleaseArch(os,
                release, channelArch);
        if ((dcm != null) && (dcm.getChannel().getProductName() != null)) {
            throw new PermissionException("It's not possible to change " +
                   dcm.getChannel().getProductName().getName() + " channel maps.");
        }

        if (channelLabel.isEmpty()) {
            // remove dist channel map
            if (dcm != null) {
                ChannelFactory.remove(dcm);
            }
            else {
                throw new NoSuchDistChannelMapException();
            }
        }
        else {
            Channel channel = ChannelFactory.lookupByLabel(channelLabel);
            if (channel == null) {
                throw new NoSuchChannelException();
            }

            if (dcm != null) {
                // update channel map
                dcm.setChannel(channel);
                ChannelFactory.save(dcm);
            }
            else {
                // create new channel map
                dcm = new DistChannelMap();
                dcm.setOs(os);
                dcm.setRelease(release);
                dcm.setChannelArch(channelArch);
                dcm.setChannel(channel);
                ChannelFactory.save(dcm);
            }
        }

        return 1;
    }
}
