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
package com.redhat.rhn.domain.test;

import com.redhat.rhn.domain.AbstractLabelNameHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * AbstractLabelNameHelperTest
 * @version $Rev$
 */
public class AbstractLabelNameHelperTest extends RhnBaseTestCase {

    public void testEquals() {
        AbstractLabelNameHelper h1 = new AbstractLabelNameHelper();
        AbstractLabelNameHelper h2 = null;
        
        h1.setLabel("foo");
        h1.setName("bar");
        h1.setId(new Long(1));
        
        assertFalse(h1.equals(h2));

        h2 = new AbstractLabelNameHelper();
        h2.setLabel("bar");
        h2.setName("foo");
        h2.setId(new Long(2));
        assertFalse(h1.equals(h2));
        
        h2.setLabel("foo");
        h2.setName("bar");
        h2.setId(null);
        assertFalse(h1.equals(h2));
        
        h2.setId(new Long(1));
        assertTrue(h1.equals(h2));
        assertTrue(h1.equals(h1));
    }
}
