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

import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.token.TokenFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;

import java.util.Map;



/**
 * ActivationKeyAclHandler
 * @version $Rev$
 */
public class ActivationKeyAclHandler extends BaseHandler implements AclHandler {
    /**
     * Returns true if the Token whose id matches the given tid,
     * has the requested entitlement given by entitlement label in param 0
     * @param ctx Context Map to pass in
     * @param params Parameters to use to fetch from Context
     * @return true if token as the entitlement checked is granted, false otherwise
     */
    public boolean aclTokenHasEntitlement(Object ctx, String[] params) {
        if (params == null) {
            return false;
        }

        Map map = (Map) ctx;
        Long tid = getAsLong(map.get(RequestContext.TOKEN_ID));
        User user = (User) map.get("user");
        Token t = TokenFactory.lookup(tid, user.getOrg());
        for (ServerGroupType sgt : t.getEntitlements()) {
            if (sgt.getLabel().equals(params[0])) {
                return true;
            }
        }
        return false;
    }
}
