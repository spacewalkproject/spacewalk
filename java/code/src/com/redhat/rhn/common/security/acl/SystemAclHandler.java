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
package com.redhat.rhn.common.security.acl;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.cobbler.SystemRecord;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * SystemAclHandler
 * @version $Rev$
 */
public class SystemAclHandler extends BaseHandler implements AclHandler {

    /**
     * Logger for this class
     */
    private static Logger log = Logger.getLogger(SystemAclHandler.class);
    
    /**
     * 
     */
    public SystemAclHandler() {
        super();
    }

    /**
     * Returns true if the client is capable of performing the given
     * task.
     * @param ctx Context Map to pass in
     * @param params Parameters to use to fetch from Context
     * @return true if the client is capable of performing the given
     * task.
     */
    public boolean aclClientCapable(Object ctx, String[] params) {
        if (params == null) {
            return false;
        }

        Map map = (Map) ctx;
        Long sid = getAsLong(map.get("sid"));
        return SystemManager.clientCapable(sid, params[0]);
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
    public boolean aclChildChannelCandidate(Object ctx, String[] params) {
        Map map = (Map) ctx;
        Long sid = getAsLong(map.get("sid"));
        String label = params[0];
        
        SelectMode m = ModeFactory.getMode("Channel_queries", "child_channel_candidate");
        Map queryParams = new HashMap();
        queryParams.put("label", label);
        queryParams.put("sid", sid);
        DataResult dr = m.execute(queryParams);
        return (dr.size() > 0);
    }
    
    /**
     * This acl is basically a combination of two others.
     * I basically lifted the logic right from the perl code.
     * @param ctx Context Map to pass in
     * @param params Parameters to use to fetch from Context
     * @return true if access is granted, false otherwise
     */
    public boolean aclSatellitePossible(Object ctx, String[] params) {
        Access handler = new Access();
        params = new String[] { "rhn-satellite" };
        return handler.aclOrgChannelFamily(ctx, params) &&
                aclChildChannelCandidate(ctx, params);
    }
    
    /**
     * FIXME not implemented. Currently this method
     * is unimplemented and ALWAYS returns false
     * @param ctx Context Map to pass in
     * @param params Parameters to use to fetch from Context
     * @return true if access is granted, false otherwise
     */
    public boolean aclSystemProfileCapable(Object ctx, String[] params) {
        // FIXME implement
        throw new UnsupportedOperationException("aclSystemProfileCapable not implemented");
    }
    
    /**
     * Uses the sid param to decide if a system is a satellite server
     * @param ctx Context Map to pass in
     * @param params Parameters to use (unused)
     * @return true if a system is a satellite, false otherwise
     */
    public boolean aclSystemIsSatellite(Object ctx, String[] params) {
        Map map = (Map) ctx;
        Long sid = getAsLong(map.get("sid"));
        
        SelectMode m = ModeFactory.getMode("System_queries", "is_satellite");
        Map queryParams = new HashMap();
        queryParams.put("sid", sid);
        DataResult dr = m.execute(queryParams);
        return (dr.size() > 0);
    }
    
    /**
     * Uses the sid param to decide if a system is a proxy server
     * @param ctx Context Map to pass in
     * @param params Parameters to use (unused)
     * @return true if a system is a proxy, false otherwise
     */
    public boolean aclSystemIsProxy(Object ctx, String[] params) {
        Map map = (Map) ctx;
        Long sid = getAsLong(map.get("sid"));
        
        SelectMode m = ModeFactory.getMode("System_queries", "is_proxy");
        Map queryParams = new HashMap();
        queryParams.put("sid", sid);
        DataResult dr = m.execute(queryParams);
        return (dr.size() > 0);
    }
    
    /**
     * Uses the sid param to decide if a system is a satellite server
     * @param ctx Context Map to pass in
     * @param params Parameters to use (unused)
     * @return true if a system is a satellite, false otherwise
     */
    public boolean aclSystemIsVirtual(Object ctx, String[] params) {
        Map map = (Map) ctx;
        Long sid = getAsLong(map.get("sid"));
        User user = (User)map.get("user");
        Server lookedUp = SystemManager.lookupByIdAndUser(sid, user);
        
        return lookedUp.isVirtualGuest();
    }
    
    /**
     * Checks to see if the system has a KickstartSession 
     * @param ctx Context Map to pass in
     * @param params Parameters to use (unused)
     * @return true if a system has a session
     */
    public boolean aclSystemKickstartSessionExists(Object ctx, String[] params) {
        Map map = (Map) ctx;
        Long sid = getAsLong(map.get("sid"));
        return (KickstartFactory.lookupKickstartSessionByServer(sid) != null); 
    }
    
    /**
     * Checks to see if a cobbler system record exists for this system  
     * @param ctx Context Map to pass in
     * @param params Parameters to use (unused)
     * @return true if a system has a session
     */
    public boolean aclCobblerSystemRecordExists(Object ctx, String[] params) {
        Map map = (Map) ctx;
        Long sid = getAsLong(map.get("sid"));
        User user = (User)map.get("user");
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        if (StringUtils.isBlank(server.getCobblerId())) {
            return false;
        }
        try {
            SystemRecord record = SystemRecord.lookupById(
                                    CobblerXMLRPCHelper.getConnection(user),
                                                    server.getCobblerId());
            return record != null;
        }
        catch (Exception e) {
            log.error("Cobbler connection errored out for Id" + 
                                                server.getCobblerId(), e);
            return false;
        }
    }
    /**
     * Checks to see if an org has proxies
     * @param ctx Context Map to pass in
     * @param params Parameters to use (unused)
     * @return true if the org has proxies
     */
    public boolean aclOrgHasProxies(Object ctx, String[] params) {
        Map map = (Map) ctx;
        User user = (User)map.get("user");
        List  proxies = ServerFactory.lookupProxiesByOrg(user);
        return proxies.size() > 0; 
    }
}
