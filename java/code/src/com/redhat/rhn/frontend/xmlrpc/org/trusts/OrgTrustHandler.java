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
package com.redhat.rhn.frontend.xmlrpc.org.trusts;

import com.redhat.rhn.common.db.datasource.DataList;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ChannelTreeNode;
import com.redhat.rhn.frontend.dto.OrgTrustOverview;
import com.redhat.rhn.frontend.dto.TrustedOrgDto;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.NoSuchOrgException;
import com.redhat.rhn.frontend.xmlrpc.OrgNotInTrustException;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.org.OrgManager;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * OrgTrustsHandler
 * @xmlrpc.namespace org.trusts
 * @xmlrpc.doc Contains methods to access common organization trust information
 * available from the web interface.
 */
public class OrgTrustHandler extends BaseHandler {

    /**
     * Lists all organizations trusted by the user's organization.
     * @param loggedInUser The current user
     * @return Returns array of channels with info such as channel_label, channel_name,
     * channel_parent_label, packages and systems.
     *
     * @xmlrpc.doc List all organanizations trusted by the user's organization.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     *     #array()
     *         $TrustedOrgDtoSerializer
     *     #array_end()
     */
    public Object[] listOrgs(User loggedInUser) {
        ensureUserRole(loggedInUser, RoleFactory.ORG_ADMIN);

        DataList<TrustedOrgDto> result = OrgManager.trustedOrgs(loggedInUser);
        return result.toArray();
    }

    /**
     * Lists all software channels that organization given is providing to the user's
     * organization.
     * @param loggedInUser The current user
     * @param trustOrgId organization id of the trusted org
     * @return Returns array of channels with info such as channel_label, channel_name,
     * channel_parent_label, packages and systems.
     *
     * @xmlrpc.doc Lists all software channels that the organization given is providing to
     * the user's organization.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("int", "trustOrgId", "Id of the trusted organization")
     * @xmlrpc.returntype
     *     #array()
     *         #struct("channel info")
     *             #prop("int", "channel_id")
     *             #prop("string", "channel_name")
     *             #prop("int", "packages")
     *             #prop("int", "systems")
     *         #struct_end()
     *     #array_end()
     */
    public Object[] listChannelsProvided(User loggedInUser, Integer trustOrgId) {

        ensureUserRole(loggedInUser, RoleFactory.ORG_ADMIN);

        Org trustOrg = OrgFactory.lookupById(new Long(trustOrgId));
        if (trustOrg == null) {
            throw new NoSuchOrgException(trustOrgId.toString());
        }

        if (!loggedInUser.getOrg().getTrustedOrgs().contains(trustOrg)) {
            // the org requested isn't in the user's trust list; therefore, this
            // request is not allowed.
            throw new OrgNotInTrustException(trustOrgId);
        }

        DataResult<ChannelTreeNode> result = ChannelManager.trustChannelConsume(
                trustOrg, loggedInUser.getOrg(), loggedInUser, null);

        return result.toArray();
    }

    /**
     * Lists all software channels that organization given may consume from the user's
     * organization.
     * @param loggedInUser The current user
     * @param trustOrgId organization id of the trusted org
     * @return Returns array of channels with info such as channel_label, channel_name,
     * channel_parent_label, packages and systems.
     *
     * @xmlrpc.doc Lists all software channels that the organization given may consume
     * from the user's organization.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("int", "trustOrgId", "Id of the trusted organization")
     * @xmlrpc.returntype
     *     #array()
     *         #struct("channel info")
     *             #prop("int", "channel_id")
     *             #prop("string", "channel_name")
     *             #prop("int", "packages")
     *             #prop("int", "systems")
     *         #struct_end()
     *     #array_end()
     */
    public Object[] listChannelsConsumed(User loggedInUser, Integer trustOrgId) {

        ensureUserRole(loggedInUser, RoleFactory.ORG_ADMIN);

        Org trustOrg = OrgFactory.lookupById(new Long(trustOrgId));
        if (trustOrg == null) {
            throw new NoSuchOrgException(trustOrgId.toString());
        }

        if (!loggedInUser.getOrg().getTrustedOrgs().contains(trustOrg)) {
            // the org requested isn't in the user's trust list; therefore, this
            // request is not allowed.
            throw new OrgNotInTrustException(trustOrgId);
        }

        DataResult<ChannelTreeNode> result = ChannelManager.trustChannelConsume(
                loggedInUser.getOrg(), trustOrg, loggedInUser, null);

        return result.toArray();
    }

    /**
     * Returns the organization trust details.
     * given the org_id.
     * @param loggedInUser The current user
     * @param trustOrgId the id of the organization to lookup on.
     * @return details on the trusted organization.
     *
     * @xmlrpc.doc The trust details about an organization given
     * the organization's ID.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "trustOrgId", "Id of the trusted organization")
     * @xmlrpc.returntype
     *     #struct("org trust details")
     *          #prop_desc("dateTime.iso8601", "created", "Date the organization was
     *          created")
     *          #prop_desc("dateTime.iso8601", "trusted_since", "Date the organization was
     *          defined as trusted")
     *          #prop_desc("int", "channels_provided", "Number of channels provided by
     *          the organization.")
     *          #prop_desc("int", "channels_consumed", "Number of channels consumed by
     *          the organization.")
     *          #prop_desc("int", "systems_migrated_to", "Number of systems migrated to
     *          the organization.")
     *          #prop_desc("int", "systems_migrated_from", "Number of systems migrated
     *          from the organization.")
     *     #struct_end()
     */
    public Map<String, Object> getDetails(User loggedInUser, Integer trustOrgId) {

        ensureUserRole(loggedInUser, RoleFactory.ORG_ADMIN);

        Org trustOrg = OrgFactory.lookupById(new Long(trustOrgId));
        if (trustOrg == null) {
            throw new NoSuchOrgException(trustOrgId.toString());
        }
        if (!loggedInUser.getOrg().getTrustedOrgs().contains(trustOrg)) {
            throw new OrgNotInTrustException(trustOrgId);
        }

        Map<String, Object> details = new HashMap<String, Object>();

        if (trustOrg.getCreated() != null) {
            details.put("created", trustOrg.getCreated());
        }

        Date since = OrgManager.getTrustedSince(loggedInUser,
                loggedInUser.getOrg(), trustOrg);
        if (since != null) {
            details.put("trusted_since", since);
        }
        details.put("channels_provided",
                OrgManager.getSharedChannels(loggedInUser,
                        trustOrg, loggedInUser.getOrg()));
        details.put("channels_consumed",
                OrgManager.getSharedChannels(loggedInUser,
                        loggedInUser.getOrg(), trustOrg));

        details.put("systems_migrated_to",
                OrgManager.getMigratedSystems(loggedInUser,
                        trustOrg, loggedInUser.getOrg()));
        details.put("systems_migrated_from",
                OrgManager.getMigratedSystems(loggedInUser,
                        loggedInUser.getOrg(), trustOrg));

        return details;
    }

    /**
     * Returns a list of organizations along with a trusted indicator.
     * @param loggedInUser The current user
     * @param orgId the id of an organization.
     * @return Returns a list of organizations along with a trusted indicator.
     * @xmlrpc.doc Returns the list of trusted organizations.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.returntype
     * $OrgTrustOverviewSerializer
     */
    public List<OrgTrustOverview> listTrusts(User loggedInUser, Integer orgId) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        Org org = OrgFactory.lookupById(Long.valueOf(orgId));
        if (org == null) {
            throw new NoSuchOrgException(orgId.toString());
        }
        return OrgManager.orgTrusts(loggedInUser, Long.valueOf(orgId));
    }

    /**
     * Add an organization to the list of <i>trusted</i> organizations.
     * @param loggedInUser The current user
     * @param orgId The id of the organization to be updated.
     * @param trustOrgId The id of the organization to be added.
     * @return 1 on success, else 0.
     * @xmlrpc.doc Add an organization to the list of trusted organizations.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.param #param("int", "trustOrgId")
     * @xmlrpc.returntype #return_int_success()
     */
    public int addTrust(User loggedInUser, Integer orgId, Integer trustOrgId) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        Org org = OrgFactory.lookupById(Long.valueOf(orgId));
        if (org == null) {
            throw new NoSuchOrgException(orgId.toString());
        }
        Org trusted = OrgFactory.lookupById(Long.valueOf(trustOrgId));
        if (trusted == null) {
            throw new NoSuchOrgException(trustOrgId.toString());
        }
        org.getTrustedOrgs().add(trusted);
        OrgFactory.save(org);
        return 1;
    }

    /**
     * Remove an organization to the list of <i>trusted</i> organizations.
     * @param loggedInUser The current user
     * @param orgId the id of the organization to be updated.
     * @param trustOrgId The id of the organization to be removed.
     * @return 1 on success, else 0.
     * @xmlrpc.doc Remove an organization to the list of trusted organizations.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.param #param("int", "trustOrgId")
     * @xmlrpc.returntype #return_int_success()
     */
    public int removeTrust(User loggedInUser, Integer orgId, Integer trustOrgId) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        Org org = OrgFactory.lookupById(Long.valueOf(orgId));
        if (org == null) {
            throw new NoSuchOrgException(orgId.toString());
        }
        Org trusted = OrgFactory.lookupById(Long.valueOf(trustOrgId));
        if (trusted == null) {
            throw new NoSuchOrgException(trustOrgId.toString());
        }
        org.getTrustedOrgs().remove(trusted);
        OrgFactory.save(org);
        return 1;
    }

    /**
     * Get a list of systems within the  <i>trusted</i> organization that would be
     * affected if the <i>trust</i> relationship was removed.  This basically lists
     * systems that are sharing at least (1) package.
     * @param loggedInUser The current user
     * @param orgId the id of <i>trusting</i> organization.
     * @param trustOrgId The id of the <i>trusted</i> organization.
     * @return A list of affected systems.
     * @xmlrpc.doc  Get a list of systems within the  <i>trusted</i> organization
     *   that would be affected if the <i>trust</i> relationship was removed.
     *   This basically lists systems that are sharing at least (1) package.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.param #param("string", "trustOrgId")
     * @xmlrpc.returntype
     *   #array()
     *     #struct("affected systems")
     *       #prop("int", "systemId")
     *       #prop("string", "systemName")
     *     #struct_end()
     *   #array_end()
     */
    public List<Map<String, Object>> listSystemsAffected(
        User loggedInUser,
        Integer orgId,
        Integer trustOrgId) {

        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        List<Map<String, Object>> subscribed =
            SystemManager.subscribedInOrgTrust(orgId, trustOrgId);
        List<Map<String, Object>> result = new ArrayList<Map<String, Object>>();
        for (Map<String, Object> sm : subscribed) {
            Map<String, Object> m = new HashMap<String, Object>();
            m.put("systemId", sm.get("id"));
            m.put("systemName", sm.get("name"));
            result.add(m);
        }
        return result;
    }
}
