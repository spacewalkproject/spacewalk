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
package com.redhat.rhn.common.security.acl.action;

import com.redhat.rhn.common.security.acl.AclHandler;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.ActionType;

import java.util.Map;

/**
 * ActionAclHandler contains ACL methods related to com.redhat.rhn.domain.action.Action
 * objects.
 *
 * @version $Rev$
 */
public class ActionAclHandler implements AclHandler {

    /**
     * Constructor for Access object
     */
    public ActionAclHandler() {
        // default constructor
    }

    /**
     * Returns true if there exists an Action which matches
     * the given id, and whose archtype matches the given
     * type. Requires an aid String in the Context.
     * @param ctx Context Map to pass in
     * @param params Parameters to use to fetch from Context
     * @return true if type type matches, false otherwise.
     */
    public boolean aclGenericActionType(Object ctx, String[] params) {
        Map map = (Map) ctx;
        String said = (String) map.get("aid");
        Long aid = new Long(said);
        Action action = ActionFactory.lookupById(aid);

        return ActionFactory.checkActionArchType(action, params[0]);
    }

    /**
     * Returns true if there is an action with the given id that
     * is one of four action types associated with solaris patches
     * @param ctx Context Map
     * @param params Parameters not used
     * @return true is patch action type; false otherwise
     */
    public boolean aclActionTypePatch(Object ctx, String[] params) {
        Map map = (Map) ctx;
        String said = (String) map.get("aid");
        Long aid = new Long(said);
        ActionType type = ActionFactory.lookupById(aid).getActionType();
        if (type.equals(ActionFactory.TYPE_SOLARISPKGS_PATCHREMOVE) ||
                type.equals(ActionFactory.TYPE_SOLARISPKGS_PATCHINSTALL) ||
                type.equals(ActionFactory.TYPE_SOLARISPKGS_PATCHCLUSTERINSTALL) ||
                type.equals(ActionFactory.TYPE_SOLARISPKGS_PATCHCLUSTERREMOVE)) {
            return true;
        }
        return false;
    }
}
