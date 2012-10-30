/**
 * Copyright (c) 2010--2012 Red Hat, Inc.
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
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelArchException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchChannelException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchDistChannelMapException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchOrgException;

import org.apache.commons.lang.StringUtils;

/**
 * DistChannelHandler - provides methods to access distribution channel information.
 * @version $Rev$
 * @xmlrpc.namespace distchannel
 * @xmlrpc.doc Provides methods to access and modify distribution channel information
 */
public class DistChannelHandler extends BaseHandler {

    /**
     * Lists the default distribution channel maps
     * @param sessionKey The sessionKey containing the logged in user
     * @return List of dist channel maps
     *
     * @xmlrpc.doc Lists the default distribution channel maps
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     *   #array("dist channel map")
     *      $DistChannelMapSerializer
     *   #array_end()
     */
    public Object[] listDefaultMaps(String sessionKey) {
        getLoggedInUser(sessionKey);
        return ChannelFactory.listAllDistChannelMaps().toArray();
    }

    /**
     * Lists distribution channel maps valid for the user's organization
     * @param sessionKey session key
     * @return List of dist channel maps
     *
     * @xmlrpc.doc Lists distribution channel maps valid for the user's organization
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     *   #array("dist channel map")
     *      $DistChannelMapSerializer
     *   #array_end()
     */
    public Object[] listMapsForOrg(String sessionKey) {
        User loggedInUser = getLoggedInUser(sessionKey);
        return ChannelFactory.listAllDistChannelMapsByOrg(loggedInUser.getOrg()).toArray();
    }

    /**
     * Lists distribution channel maps valid for an organization,
     * satellite admin right needed
     * @param sessionKey session key
     * @param orgId organization id
     * @return List of dist channel maps
     *
     * @xmlrpc.doc Lists distribution channel maps valid for an organization,
     * satellite admin right needed
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.returntype
     *   #array("dist channel map")
     *      $DistChannelMapSerializer
     *   #array_end()
     */
    public Object[] listMapsForOrg(String sessionKey, Integer orgId) {
        User loggedInUser = getLoggedInUser(sessionKey);
        if (!loggedInUser.hasRole(RoleFactory.SAT_ADMIN)) {
            throw new PermissionException(RoleFactory.SAT_ADMIN);
        }
        Org org = OrgFactory.lookupById(new Long(orgId));
        if (org == null) {
            throw new NoSuchOrgException(orgId.toString());
        }

        return ChannelFactory.listAllDistChannelMapsByOrg(org).toArray();
    }

    /**
     * Sets, overrides (/removes if channelLabel empty) a distribution channel map
     * within an organization
     * @param sessionKey The sessionKey containing the logged in user
     * @param os OS
     * @param release Relase
     * @param archName architecture label
     * @param channelLabel channel label
     * @return Returns 1 if successful, exception otherwise
     *
     * @xmlrpc.doc Sets, overrides (/removes if channelLabel empty)
     * a distribution channel map within an organization
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "os")
     * @xmlrpc.param #param("string", "release")
     * @xmlrpc.param #param("string", "archName")
     * @xmlrpc.param #param("string", "channelLabel")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setMapForOrg(String sessionKey, String os, String release,
                                            String archName, String channelLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);
        if (!loggedInUser.hasRole(RoleFactory.ORG_ADMIN)) {
            throw new PermissionException(RoleFactory.ORG_ADMIN);
        }
        Org org = loggedInUser.getOrg();

        ChannelArch channelArch = ChannelFactory.lookupArchByName(archName);
        if (channelArch == null) {
            throw new InvalidChannelArchException(archName);
        }
        Channel channel = null;
        if (!StringUtils.isEmpty(channelLabel)) {
            channel = ChannelFactory.lookupByLabel(channelLabel);
            if (channel == null) {
                throw new NoSuchChannelException(channelLabel);
            }
        }

        DistChannelMap dcm = ChannelFactory.lookupDistChannelMapByOrgReleaseArch(
                org, release, channelArch);

        if (channel == null) {
            // remove
            if (dcm == null || dcm.getOrg() == null) {
                throw new NoSuchDistChannelMapException();
            }
            ChannelFactory.remove(dcm);
            return 1;
        }
        // channel != null
        if (dcm == null || dcm.getOrg() == null) {
            // create
            dcm = new DistChannelMap(org, os, release, channelArch, channel);
            ChannelFactory.save(dcm);
        }
        else {
            // update
            dcm.setOs(os);
            dcm.setChannel(channel);
            ChannelFactory.save(dcm);
        }
        return 1;
    }
}
