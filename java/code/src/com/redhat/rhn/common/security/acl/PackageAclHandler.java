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

import com.redhat.rhn.domain.common.ArchType;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.token.TokenFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnpackage.PackageManager;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.util.Map;
import java.util.Set;

/**
 * ActivationKeyAclHandler
 * @version $Rev$
 */
public class PackageAclHandler extends BaseHandler implements AclHandler {

    private final Log log = LogFactory.getLog(this.getClass());

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

    /**
     * Tests to determine if the requested package is capable with the given ACLs.
     *
     * @param ctx context map describing the request
     * @param params Parameters to use to fetch from context
     * @return true if the the package passes the ACL
     */
    public boolean aclPackageTypeCapable(Object ctx, String[] params) {

        if (params.length == 0) {
            return false;
        }

        String cap = params[0];
        Map map = (Map) ctx;

        User user = (User) map.get("user");
        Long pid = getAsLong(map.get("pid"));
        Package pack = PackageManager.lookupByIdAndUser(pid, user);

        if (user == null || pid == null || pack == null) {
            return false;
        }

        ArchType type = pack.getPackageArch().getArchType();
        String archTypeLabel = type.getLabel();
        Map<String, Set<String>> capMap = PackageFactory.getPackageCapabilityMap();

        if (capMap.get(archTypeLabel) == null) {
            return false;
        }

        Set<String> capabilities = capMap.get(archTypeLabel);

        boolean capFound = capabilities.contains(cap);
        return capFound;
    }

}
