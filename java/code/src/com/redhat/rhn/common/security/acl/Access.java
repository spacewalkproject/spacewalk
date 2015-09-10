/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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
package com.redhat.rhn.common.security.acl;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Access is a concrete implementation of an AclHandler.
 * This is default implementation which is always included
 * when evaluating {@link Acl Acls}.
 */
public class Access extends BaseHandler {

    protected static final Logger LOG = Logger.getLogger(Access.class);

    /**
     * Constructor for Access object
     */
    public Access() {
        super();
    }

    /**
     * Returns true if the User whose uid matches the given uid, is
     * in the given Role. Requires a uid String in the Context.
     * @param ctx Context Map to pass in
     * @param params Parameters to use to fetch from Context
     * @return true if access is granted, false otherwise
     */
    public boolean aclUidRole(Object ctx, String[] params) {
        Map map = (Map) ctx;
        Long uid = getAsLong(map.get("uid"));
        User user = UserFactory.lookupById(uid);
        return user.hasRole(RoleFactory.lookupByLabel(params[0]));
    }

    /**
     * Returns true if current User is in the Role.
     * Requires a User in the Context.
     * @param ctx Context Map to pass in
     * @param params Parameters to use to fetch from Context
     * @return true if access is granted, false otherwise
     */
    public boolean aclUserRole(Object ctx, String[] params) {
        Map map = (Map) ctx;
        User user = (User) map.get("user");
        if (user != null) {
            boolean retval = user.hasRole(RoleFactory.lookupByLabel(params[0]));
            if (LOG.isDebugEnabled()) {
                LOG.debug(params[0] + " aclUserRole | A returning " + retval);
            }
            return retval;
        }
        if (LOG.isDebugEnabled()) {
            LOG.debug(params[0] + " aclUserRole | B returning false ..");
        }
        return false;
    }

    /**
     * Returns true if the given value in the param is found in
     * the global configuration.
     * @param ctx Context Map to pass in
     * @param params Parameters to use to fetch from Context
     * @return true if access is granted, false otherwise
     */
    public boolean aclIs(Object ctx, String[] params) {
        if (params == null || params.length < 1) {
            // FIXME: need to localize exception text
            throw new IllegalArgumentException("Invalid number of parameters.");
        }
        return Config.get().getBoolean(params[0]);
    }

    /**
     * TODO: Right now this method calls a small little query
     * very similar to how the perl code decides this acl.
     * IMO, there is a better way, and we should fix this when
     * we migrate the channels tab.
     * @param ctx Context Map to pass in
     * @param params Parameters to use to fetch from Context
     * @return true if access is granted, false otherwise
     */
    public boolean aclOrgChannelFamily(Object ctx, String[] params) {
        Map map = (Map) ctx;
        User user = (User) map.get("user");
        String label = params[0];

        SelectMode m = ModeFactory.getMode("Org_queries",
                "has_channel_family_entitlement");
        Map queryParams = new HashMap();
        queryParams.put("label", label);
        queryParams.put("org_id", user.getOrg().getId());
        DataResult dr = m.execute(queryParams);
        return (dr.size() > 0);
    }

    /**
     * Does the org have any proxies?
     * @param ctx Context Map to pass in
     * @param params Parameters to use to fetch from Context
     * @return true if the org has proxies, false otherwise
     */
    public boolean aclOrgHasProxies(Object ctx, String[] params) {
        Map map = (Map) ctx;
        User user = (User) map.get("user");

        SelectMode m = ModeFactory.getMode("System_queries",
                "org_proxy_servers");
        Map queryParams = new HashMap();
        queryParams.put("org_id", user.getOrg().getId());
        DataResult dr = m.execute(queryParams);
        return (dr.size() > 0);
    }

    /**
     * Check if a System has a feature
     * @param ctx Context Map to pass in
     * @param params Parameters to use to fetch from Context
     * @return true if access is granted, false otherwise
     */
    public boolean aclSystemFeature(Object ctx, String[] params) {
        Map map = (Map) ctx;
        Long sid = getAsLong(map.get("sid"));
        String feature = params[0];

        return SystemManager.serverHasFeature(sid, feature);
    }

    /**
     * Check if a system has virtualization entitlements.
     * @param ctx Context map to pass in.
     * @param params Parameters to use to fetch from context.
     * @return True if system has virtualization entitlement, false otherwise.
     */
    public boolean aclSystemHasVirtualizationEntitlement(Object ctx, String[] params) {
        Map map = (Map) ctx;
        Long sid = getAsLong(map.get("sid"));
        User user = (User) map.get("user");

        return SystemManager.serverHasVirtuaizationEntitlement(sid, user.getOrg());
    }

    /**
     * Check if a system has a management entitlement
     * @param ctx Context map to pass in.
     * @param params Parameters to use to fetch from context.
     * @return True if system has management entitlement, false otherwise.
     */
    public boolean aclSystemHasManagementEntitlement(Object ctx, String[] params) {
        Map map = (Map) ctx;
        Long sid = getAsLong(map.get("sid"));
        User user = (User) map.get("user");
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        if (server == null) {
            return false;
        }
        return server.hasEntitlement(EntitlementManager.MANAGEMENT);
    }

    /**
     * Uses the sid param to decide if a system is a virtual guest
     * @param ctx Context Map to pass in
     * @param params Parameters to use (unused)
     * @return true if a system is a satellite, false otherwise
     */
    public boolean aclSystemIsVirtual(Object ctx, String[] params) {
        Map map = (Map) ctx;
        Long sid = getAsLong(map.get("sid"));
        User user = (User) map.get("user");
        Server lookedUp = SystemManager.lookupByIdAndUser(sid, user);

        return lookedUp.isVirtualGuest();
    }

    /**
     * Check if a system has a management entitlement
     * @param ctx Context map to pass in.
     * @param params Parameters to use to fetch from context.
     * @return True if system has management entitlement, false otherwise.
     */
    public boolean aclSystemIsInSSM(Object ctx, String[] params) {
        Map map = (Map) ctx;
        Long sid = getAsLong(map.get("sid"));
        User user = (User) map.get("user");
        RhnSet set = RhnSetDecl.SYSTEMS.get(user);
        return set.contains(sid);
    }

    /**
     * Checks if the User's Org has the requested Role.
     * Requires a User in the Context object.
     * @param ctx Context Map to pass in
     * @param params Used to specify the Role label
     * @return true if access is granted, false otherwise
     */
    public boolean aclOrgRole(Object ctx, String[] params) {
        Map map = (Map) ctx;
        User user = (User)map.get("user");
        if (user != null) {
            Org org = user.getOrg();
            return org.hasRole(RoleFactory.lookupByLabel(params[0]));
        }

        return false;
    }

    /**
     * Returns true if the User has been authenticated by the system.
     * @param ctx Context Map to pass in
     * @param params Not used
     * @return true if access is granted, false otherwise
     */
    public boolean aclUserAuthenticated(Object ctx, String[] params) {
        Map map = (Map) ctx;
        User user = (User)map.get("user");
        return (user != null);
    }

    /**
     * Returns true if the system is a satellite and has any users.
     * NOTE: this is an expensive call with many many users.  It is intended
     * to be called from the installer.
     * @param ctx acl context
     * @param p parameters for acl (ignored)
     * @return true if the system is a satellite and has any users.
     */
    public boolean aclNeedFirstUser(Object ctx, String[] p) {
        boolean flag = !(UserFactory.satelliteHasUsers());
        return flag;
    }

    /**
     * returns true or false ifthe user has access to a channel
     * @param ctx acl context
     * @param params params need the channel id as param 0
     * @return true if has read access false otherwise
     */
    public boolean aclCanAccessChannel(Object ctx, String[] params) {
        Map map = (Map) ctx;
        User user = (User) map.get("user");

        try {
            if (user != null) {
                Channel chan = ChannelManager.lookupByIdAndUser(
                        Long.parseLong(params[0]), user);
                return chan != null;
            }
        }
        catch (Exception e) {
            return false;
        }
        return false;
    }


    /**
     * Returns true if the user is either a channel administrator or an
     * org administrator
     * @param ctx acl context
     * @param params parameters for acl (ignored)
     * @return true if the user is either a channel admin or org admin
     */
    public boolean aclUserCanManageChannels(Object ctx, String[] params) {
        Map map = (Map) ctx;
        User user = (User) map.get("user");
        if (user != null) {
            List chans = UserManager.channelManagement(user, null);
            return (user.hasRole(RoleFactory.CHANNEL_ADMIN)) || chans.size() > 0;
        }

        return false;
    }

    /**
     * Returns true if the query param exists.
     * @param ctx acl context
     * @param params parameters for acl (ignored)
     * @return true if the query param exists.
     */
    public boolean aclFormvarExists(Object ctx, String[] params) {
        Map map = (Map) ctx;
        if (params.length < 1) {
            return false;
        }

        return map.get(params[0]) != null;
    }

    /**
     *
     * @param ctx acl context
     * @param params parameters for acl (ignored)
     * @return true if user org is owner of channel
     */
    public boolean aclTrustChannelAccess(Object ctx, String[] params) {
        Map map = (Map) ctx;
        User user = (User) map.get("user");
        Long cid = getAsLong(map.get("cid"));
        Channel c = ChannelFactory.lookupById(cid);

        return c.getOrg().getId() == user.getOrg().getId();
    }

    /**
     *
     * @param ctx acl context
     * @param params parameters for acl
     * @return if channel is protected
     */
    public boolean aclIsProtected(Object ctx, String[] params) {
        Map map = (Map) ctx;
        Long cid = getAsLong(map.get("cid"));
        Channel c = ChannelFactory.lookupById(cid);
        return c.isProtected();
    }

    /**
     * See if the erratum isn't a Red Hat erratum
     * @param ctx Our current context, containing the erratum
     * @param params nevim, dal
     * @return whether the erratum isn't a Red Hat erratum
     */
    public boolean aclErrataEditable(Object ctx, String[] params) {
        Map map = (Map)ctx;
        Long eid = getAsLong(map.get("eid"));
        Errata e = ErrataFactory.lookupById(eid);
        if (e == null || e.getOrg() == null) {
            return false;
        }
        return true;
    }
}
