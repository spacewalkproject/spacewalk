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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;

import java.util.Map;

/**
 * SystemAclHandler
 * @version $Rev: 54296 $
 */
public class MonitoringAclHandler extends BaseHandler implements AclHandler {

    /**
     * 
     */
    public MonitoringAclHandler() {
        super();
    }

    /**
     * Check to see if Monitoring is turned on and if the 
     * User is a MONITORING_ADMIN or not.
     * @param ctx Context Map to pass in
     * @param params Parameters to use to fetch from Context
     * @return true if access is granted, false otherwise
     */
    public boolean aclShowMonitoring(Object ctx, String[] params) {
        Map map = (Map) ctx;
        User user = (User) map.get("user");
        return checkMonitoring(user) && user.hasRole(RoleFactory.MONITORING_ADMIN);
    }

    /**
     * Check to see if Monitoring or Scout is turned on and if the
     * User is a MONITORING_ADMIN or not and if we should then
     * display details about monitoring scout
     * @param ctx Context Map to pass in
     * @param params Parameters to use to fetch from Context
     * @return true if access is granted, false otherwise
     */
    public boolean aclShowScout(Object ctx, String[] params) {
        Map map = (Map) ctx;
        User user = (User) map.get("user");
        return user.hasRole(RoleFactory.MONITORING_ADMIN) && (
            Config.get().getBoolean(ConfigDefaults.WEB_IS_MONITORING_SCOUT) ||
            Config.get().getBoolean(ConfigDefaults.WEB_IS_MONITORING_BACKEND));
    }
    
    /**
     * Check to see if Monitoring is turned on and if the 
     * User is a MONITORING_ADMIN or not.
     * @param ctx Context Map to pass in
     * @param params Parameters to use to fetch from Context
     * @return true if access is granted, false otherwise
     */
    public boolean aclOrgHasScouts(Object ctx, String[] params) {
        Map map = (Map) ctx;
        User user = (User) map.get("user");
        return (checkMonitoring(user) && 
                user.getOrg().getMonitoringScouts() != null &&
                user.getOrg().getMonitoringScouts().size() > 0);
    }
}
