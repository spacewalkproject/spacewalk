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
package com.redhat.rhn.frontend.xmlrpc.channel.org;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.InvalidChannelRoleException;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.OrgChannelDto;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelAccessException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchChannelException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchOrgException;
import com.redhat.rhn.frontend.xmlrpc.NotPermittedByOrgException;
import com.redhat.rhn.frontend.xmlrpc.OrgNotInTrustException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.org.OrgManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ChannelOrgHandler
 * @version $Rev$
 * @xmlrpc.namespace channel.org
 * @xmlrpc.doc Provides methods to retrieve and alter organization trust
 * relationships for a channel.
 */
public class ChannelOrgHandler extends BaseHandler {

    /**
     * List the organizations associated with the given channel that may be trusted.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel
     * @return List of map entries indicating the orgs available and if access is enabled.
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionKey is invalid
     *   - The channelLabel is invalid
     *   - The user doesn't have channel admin permissions
     *
     * @xmlrpc.doc List the organizations associated with the given channel
     * that may be trusted.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "label of the channel")
     * @xmlrpc.returntype 
     *   #array("organizations")
     *      #struct("org")
     *          #prop("int", "org_id")
     *          #prop("string", "org_name")
     *          #prop("boolean", "access_enabled")
     *     #struct_end()
     *  #array_end()
     */
    public List list(String sessionKey, String channelLabel) 
        throws FaultException {
        
        User user = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(user, channelLabel);
        verifyChannelAdmin(user, channel);
        
        if (!user.getOrg().equals(channel.getOrg())) {
            // users are not allowed to access properties for a channel that is in a 
            // different org
            throw new NotPermittedByOrgException(user.getOrg().getId().toString(), 
                    channel.getLabel(), channel.getOrg().getId().toString());
        }
        
        // retrieve the orgs available to be "trusted" for this channel
        List<OrgChannelDto> orgs = OrgManager.orgChannelTrusts(channel.getId(), 
                user.getOrg());
        // retrieve the orgs that are trusted for this channel
        Set<Org> trustedOrgs = channel.getTrustedOrgs();
        
        // populate a result that includes all orgs that could be trusted with a boolean
        // that indicates if the orgs is indeed trusted.
        List<Map<String, Object>> result = new ArrayList<Map<String, Object>>();
        for (OrgChannelDto orgDto : orgs) {
            Org org = OrgFactory.lookupById(orgDto.getId());                    

            if (org != null) {
                Map<String, Object> entry = new HashMap<String, Object>();

                entry.put("org_id", org.getId().intValue());
                entry.put("org_name", org.getName());
                if (trustedOrgs.contains(org)) {
                    entry.put("access_enabled", Boolean.TRUE);
                }
                else {
                    entry.put("access_enabled", Boolean.FALSE);
                }
                result.add(entry);
            }
        }
        return result;
    }

    /**
     * Enable access to the channel for the given organization.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel to change
     * @param orgId The org id being granted access.
     * @return Returns 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionkey is invalid
     *   - The channel label is invalid
     *   - The org id is invalid
     *   - The user doesn't have channel admin permissions
     *
     * @xmlrpc.doc Enable access to the channel for the given organization.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "label of the channel")
     * @xmlrpc.param #param_desc("int", "orgId", "id of org being granted access")
     * @xmlrpc.returntype  #return_int_success()
     */
    public int enableAccess(String sessionKey, String channelLabel, Integer orgId) 
        throws FaultException {
        
        return enableAccess(sessionKey, channelLabel, orgId, true);
    }
    
    /**
     * Disable access to the channel for the given organization.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel to change
     * @param orgId The org id being removed access.
     * @return Returns 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionkey is invalid
     *   - The channel label is invalid
     *   - The org id is invalid
     *   - The user doesn't have channel admin permissions
     *
     * @xmlrpc.doc Disable access to the channel for the given organization.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "label of the channel")
     * @xmlrpc.param #param_desc("int", "orgId", "id of org being removed access")
     * @xmlrpc.returntype  #return_int_success()
     */
    public int disableAccess(String sessionKey, String channelLabel, Integer orgId) 
        throws FaultException {
        
        return enableAccess(sessionKey, channelLabel, orgId, false);
    }

    private int enableAccess(String sessionKey, String channelLabel, Integer orgId,
            boolean enable) throws FaultException {
        User user = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(user, channelLabel);
        verifyChannelAdmin(user, channel);

        if (!user.getOrg().equals(channel.getOrg())) {
            // users are not allowed to alter properties for a channel that is in a 
            // different org
            throw new NotPermittedByOrgException(user.getOrg().getId().toString(), 
                    channel.getLabel(), channel.getOrg().getId().toString());
        }
        
        // protected mode only for modifying individual orgs
        if (!channel.getAccess().equals(Channel.PROTECTED)) {           
            throw new InvalidChannelAccessException(channel.getAccess());
        }
        
        Org org = OrgFactory.lookupById(orgId.longValue());      
        if (org == null) {
            throw new NoSuchOrgException(orgId.toString());
        }

        // need to validate that the org provided is in the list of orgs that may
        // be granted access
        List<OrgChannelDto> orgs = OrgManager.orgChannelTrusts(channel.getId(), 
                user.getOrg());
        boolean orgInTrust = false;
        
        for (OrgChannelDto orgDto : orgs) {
            if (orgDto.getId().equals(new Long(orgId))) {
                orgInTrust = true;
                break;
            }
        }
        
        if (orgInTrust) {
            if (enable) {
                channel.getTrustedOrgs().add(org);
            }
            else {
                channel.getTrustedOrgs().remove(org);
            }
            ChannelFactory.save(channel);
        }
        else {
            throw new OrgNotInTrustException(orgId);
        }

        return 1;
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
