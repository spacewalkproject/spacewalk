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
package com.redhat.rhn.frontend.struts.test;

import com.redhat.rhn.frontend.struts.RhnActionMapping;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * RhnActionMappingTest
 * @version $Rev$
 */
public class RhnActionMappingTest extends RhnBaseTestCase {

    public void testAclMapping() {
        //represents what some fool may put into struts-config
        String aclstring = ",,foo ,, , bar   ,baz";
        String mixins = "test";
        
        RhnActionMapping mapping = new RhnActionMapping();
        
        mapping.setAcls(aclstring);
        mapping.setMixins(mixins);
        assertEquals(aclstring, mapping.getAcls());
        assertEquals(mixins, mapping.getMixins());
    }
}
