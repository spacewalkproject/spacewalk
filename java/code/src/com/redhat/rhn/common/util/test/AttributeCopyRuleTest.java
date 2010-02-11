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

package com.redhat.rhn.common.util.test;

import com.redhat.rhn.common.util.AttributeCopyRule;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import org.apache.commons.digester.Digester;

import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class AttributeCopyRuleTest extends RhnBaseTestCase {
    public void testCopy() throws Exception {
        Digester digester = new Digester();
        digester.setValidating(false);

        digester.addObjectCreate("dummy", DummyObject.class);
        digester.addRule("dummy", new AttributeCopyRule());

        URL url = TestUtils.findTestData("dummy-test.xml");
        DummyObject result =
            (DummyObject)digester.parse(url.openStream());

        Map expected = new HashMap();
        expected.put("foo", "1");
        expected.put("bar", "baz");

        Iterator i;
        i = expected.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry me = (Map.Entry)i.next();

            assertNotNull(result.getValues().get(me.getKey()));
            assertEquals(result.getValues().get(me.getKey()),
                         me.getValue());
        }

        i = result.getValues().entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry me = (Map.Entry)i.next();

            assertNotNull(expected.get(me.getKey()));
            assertEquals(expected.get(me.getKey()),
                         me.getValue());
        }
    }
}


