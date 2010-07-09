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
package com.redhat.rhn.manager.acl;

import com.redhat.rhn.common.security.acl.Acl;
import com.redhat.rhn.common.security.acl.AclFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * AclManager
 * @version $Rev$
 */
public class AclManager {

    private AclManager() {
        // hidden constructor
    }

    /**
     * Returns whether or not a specified acl is possessed
     * @param acl The acl required
     * @param request The request
     * @param mixins Any mixins with this acl
     * @return has acl boolean
     */
    public static boolean hasAcl(String acl, HttpServletRequest request,
            String mixins) {
        if (acl == null || "".equals(acl)) {
            return true;
        }
        return hasAcl(acl, new RequestContext(request).getLoggedInUser(), mixins,
                new HashMap(request.getParameterMap()));
    }

    /**
     * Returns whether or not a specified acl is possessed
     * @param acl The acl required
     * @param user The user object needed for verification.
     * @param mixins Any mixins with this acl
     * @param context Context object thats used by the acl mixin to evaluate data,
     *                this needs to be a writable Map or can be null if there is no data.
     * @return has acl boolean
     */
    public static boolean hasAcl(String acl, User user, String mixins,
            Map context) {
        if (acl == null || "".equals(acl)) {
            return true;
        }
        // TODO: Lifecycle issue
        // It's not cool that we're instantiating a new
        // Acl everytime we need to use it. We should register
        // the acl handlers at startup and simply call acl.evalAcl()
        // when needed.
        Acl aclObj = AclFactory.getInstance().getAcl(mixins);
        if (context == null) {
           context = new HashMap();
        }

        if (user != null) {
            context.put("user", user);
        }

        return (aclObj.evalAcl(context, acl));
    }
}
