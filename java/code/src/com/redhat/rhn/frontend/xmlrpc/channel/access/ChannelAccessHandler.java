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
package com.redhat.rhn.frontend.xmlrpc.channel.access;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.InvalidChannelRoleException;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidAccessValueException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchChannelException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.manager.channel.ChannelManager;

/**
 * ChannelAccessHandler
 * @version $Rev$
 * @xmlrpc.namespace channel.access
 * @xmlrpc.doc Provides methods to retrieve and alter channel access restrictions.
 */
public class ChannelAccessHandler extends BaseHandler {

    /**
     * Enable user restrictions for the given channel. If enabled, only
     * selected users within the organization may subscribe to the channel.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel to change
     * @return Returns 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionkey is invalid
     *   - The channel label is invalid
     *   - The user doesn't have channel admin permissions
     *
     * @xmlrpc.doc Enable user restrictions for the given channel. If enabled, only
     * selected users within the organization may subscribe to the channel.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "label of the channel")
     * @xmlrpc.returntype  #return_int_success()
     */
    public int enableUserRestrictions(String sessionKey, String channelLabel)
        throws FaultException {

        User user = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(user, channelLabel);
        verifyChannelAdmin(user, channel);

        channel.setGloballySubscribable(false, user.getOrg());
        ChannelFactory.save(channel);

        return 1;
    }

    /**
     * Disable user restrictions for the given channel. If disabled,
     * all users within the organization may subscribe to the channel.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel to change
     * @return Returns 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionkey is invalid
     *   - The channel label is invalid
     *   - The user doesn't have channel admin permissions
     *
     * @xmlrpc.doc Disable user restrictions for the given channel.  If disabled,
     * all users within the organization may subscribe to the channel.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "label of the channel")
     * @xmlrpc.returntype  #return_int_success()
     */
    public int disableUserRestrictions(String sessionKey, String channelLabel)
        throws FaultException {

        User user = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(user, channelLabel);
        verifyChannelAdmin(user, channel);

        channel.setGloballySubscribable(true, user.getOrg());
        ChannelFactory.save(channel);

        return 1;
    }

    /**
     * Set organization sharing access control.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel to change
     * @param access The access value to set. (Must be one of the following:
     * "public", "private" or "protected")
     * @return Returns 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionKey is invalid
     *   - The channelLabel is invalid
     *   - The access is invalid
     *   - The user doesn't have channel admin permissions
     *
     * @xmlrpc.doc Set organization sharing access control.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "label of the channel")
     * @xmlrpc.param #prop_desc("string", "access", "Access (one of the
     *                  following: 'public', 'private', or 'protected'")
     * @xmlrpc.returntype  #return_int_success()
     */
    public int setOrgSharing(String sessionKey, String channelLabel, String access)
        throws FaultException {

        User user = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(user, channelLabel);
        verifyChannelAdmin(user, channel);

        if (channel.isValidAccess(access)) {
            channel.setAccess(access);
            ChannelFactory.save(channel);
        }
        else {
            throw new InvalidAccessValueException(access);
        }
        return 1;
    }

    /**
     * Get organization sharing access control.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel
     * @return The access value
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionKey is invalid
     *   - The channelLabel is invalid
     *   - The access is invalid
     *   - The user doesn't have channel admin permissions
     *
     * @xmlrpc.doc Get organization sharing access control.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "label of the channel")
     * @xmlrpc.returntype string - The access value (one of the following: 'public',
     * 'private', or 'protected'.
     */
    public String getOrgSharing(String sessionKey, String channelLabel)
        throws FaultException {

        User user = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(user, channelLabel);
        verifyChannelAdmin(user, channel);

        return channel.getAccess();
    }

    private Channel lookupChannelByLabel(User user, String label)
        throws NoSuchChannelException {

        Channel channel = ChannelFactory.lookupByLabelAndUser(label, user);
        if (channel == null) {
            throw new NoSuchChannelException();
        }

        return channel;
    }

    private boolean verifyChannelAdmin(User user, Channel channel) {
        try {
            if (!ChannelManager.verifyChannelAdmin(user, channel.getId())) {
                throw new PermissionCheckFailureException();
            }
        }
        catch (InvalidChannelRoleException e) {
            throw new PermissionCheckFailureException();
        }
        return true;
    }
}
