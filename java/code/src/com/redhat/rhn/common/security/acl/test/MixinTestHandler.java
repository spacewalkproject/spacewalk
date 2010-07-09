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
package com.redhat.rhn.common.security.acl.test;

import com.redhat.rhn.common.security.acl.AclHandler;

/**
 * Test AclHandler so we can test Mixins
 *
 * @version $Rev$
 */
public class MixinTestHandler implements AclHandler {

    /**
     * Constructor for Access object
     */
    public MixinTestHandler() {
    }

    /**
     * Returns true if the User whose uid matches the given uid, is
     * in the given Role. Requires a uid String in the Context.
     * @param ctx Context Map to pass in
     * @param params Parameters to use to fetch from Context
     * @return true if access is granted, false otherwise
     */
    public boolean aclMixinTest(Object ctx, String[] params) {
        return true;
    }

}
