/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import java.util.List;
import java.util.Map;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.logging.Log;

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
     * Is the package of a certain type
     * @param ctx Context Map to pass in
     * @param params Parameters to use to fetch from Context
     * @return true if the only param matches the package's arch type 
     */
    public boolean aclPackageTypeCapable(Object ctx, String[] params) {
        
        /* 495506 - Increased the logging since I can't reliably reproduce the issue.
           I'll make this quiet again when we figure out why this incorrectly returns
           false on the Satellite 5.3 builds.
           jdobies, May 12, 2009
         */
        
        if (params.length == 0) {
            log.warn("Incorrect number of parameters specified to ACL check");
            return false;
        }
        
        String cap = params[0];
        Map map = (Map) ctx;
        
        User user = (User) map.get("user");
        Long pid = getAsLong(map.get("pid"));
        Package pack = PackageManager.lookupByIdAndUser(pid, user);
        
        if (user == null || pid == null || pack == null) {
            log.warn("Check for capability [" + cap + "] is false. Package: " + pack);
            return false;
        }
          
        ArchType type = pack.getPackageArch().getArchType();
        Map<ArchType, List<String>> capMap = PackageFactory.getPackageCapabilityMap();
        
        if (capMap.get(type) == null) {
            log.warn("Check for capability [" + cap + "] on type [" + type +
                     "] is false. Type not found in map. Map contents:");
            for (ArchType typeKey : capMap.keySet()) {
                log.warn("Type key: " + typeKey);
            }
            return false;
        }
       
        boolean capFound = capMap.get(type).contains(cap);
        
        if (!capFound) {
            log.warn("Check for capability [" + cap + "] on type [" + type + 
                     "] is false. Capability not found in map.");
        }
        
        return capFound;
    }
    
}
