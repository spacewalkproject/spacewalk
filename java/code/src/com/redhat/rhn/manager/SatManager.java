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
package com.redhat.rhn.manager;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * OrgManager - Manages MultiOrg tasks
 * @version $Rev$
 */
public class SatManager extends BaseManager {
    private static final SatManager MANAGER = new SatManager();

    private SatManager() {
    }

    /**
     *
     * @return retuns the instance
     */
    public static SatManager getInstance() {
        return MANAGER;
    }

    /**
     * Returns a list of the activate satellite admins. If none exist,
     * returns Empty list.
     * @return a list of the activate satellite admins.
     */
    public static List getActiveSatAdmins() {
        SelectMode m = ModeFactory.getMode("User_queries", "active_sat_admins");
        Map params = new HashMap();
        DataResult dr = m.execute(params);
        if (dr == null) {
            return Collections.EMPTY_LIST;
        }
        return dr;
    }

    /**
     * Grants the sat admin role to the 'assignee'
     * @param assignee The user to whom sat admin role is to be granted
     * @param satAdmin the satAdmin user who is granting the role
     */
    public void grantSatAdminRoleTo(User assignee, User satAdmin) {
        ensureSatAdminRole(satAdmin);
        assignee.addRole(RoleFactory.SAT_ADMIN);
    }

    /**
     * Revokes the sat admin role from the 'revokee'
     * @param revokee The satadmin from whom the sat admin role is to be revoked.
     * @param revoker the satAdmin user who is Revoking the role from the revokee
     */
    public void revokeSatAdminRoleFrom(User revokee, User revoker) {
        ensureSatAdminRole(revoker);
        if (revokee.hasRole(RoleFactory.SAT_ADMIN)) {
            if (SatManager.getActiveSatAdmins().size() == 1) {
                ValidatorException.raiseException("satadmin.jsp.error.lastsatadmin",
                                                                revokee.getLogin());
            }
            revokee.removeRole(RoleFactory.SAT_ADMIN);
        }
    }

    /**
     * Basically throws an error if the user is not a sat admin
     * @param user the user claiming to be a sat admin
     */
    private void ensureSatAdminRole(User user) {
        if (!user.hasRole(RoleFactory.SAT_ADMIN)) {
            ValidatorException.raiseException("satadmin.jsp.error.notsatadmin",
                                user.getLogin());
        }
    }
}
