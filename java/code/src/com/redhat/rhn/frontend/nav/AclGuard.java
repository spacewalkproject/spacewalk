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
package com.redhat.rhn.frontend.nav;

import com.redhat.rhn.common.security.acl.Acl;
import com.redhat.rhn.common.security.acl.AclFactory;

import java.util.Map;

/**
 * AclGuard
 * @version $Rev$
 */
public class AclGuard implements RenderGuard {
    private Map context;
    private String mixins;
    
    
    /**
     * Constructor
     * @param ctx Acl Context
     * @param mixinsIn The string of classnames used to add extra Acl Handlers 
     */
    public AclGuard(Map ctx, String mixinsIn) {
        super();
        context = ctx;
        this.mixins = mixinsIn;
    }

    /**
     * Constructor
     * @param ctx Acl Context
     */
    public AclGuard(Map ctx) {
        this(ctx, null);
    }
    
    /**
     * Returns true if the acl of the NavNode evaluates to true.
     * Returns false otherwise.
     * @param node NavNode whose Acl is checked.
     * @param depth ignored.
     * @return true if the acl of the NavNode evalutes to true.
     */
    public boolean canRender(NavNode node, int depth) {
        // we ignore depth
        if (node == null) {
            return true;
        }
        
        String aclStr = node.getAcl();
        if (aclStr == null || "".equals(aclStr)) {
            return true;
        }
        
        Acl acl = AclFactory.getInstance().getAcl(mixins);
        boolean rc = acl.evalAcl(context, aclStr);
        return rc;
    }
}

