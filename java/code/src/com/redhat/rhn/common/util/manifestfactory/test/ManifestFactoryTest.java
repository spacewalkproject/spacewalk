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

package com.redhat.rhn.common.util.manifestfactory.test;
import com.redhat.rhn.common.util.manifestfactory.ManifestFactoryLookupException;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.Collection;
import java.util.List;

/**
 * ManifestFactory, a class to assist in turning manifest xml files
 * into factories of other classes
 *
 * @version $Rev$
 */

public class ManifestFactoryTest extends RhnBaseTestCase {
    
    private boolean threadsFail = false; 
    
    public void testFactory() throws Exception {
        String s = (String)PrimitiveFactory.getObject("string-object-foo");
        assertEquals("Foo", s);

        Integer i = (Integer)PrimitiveFactory.getObject("integer-object");
        assertEquals(new Integer(17), i);

        List l = (List)PrimitiveFactory.getObject("list-object");
        assertEquals(l.size(), 12);
        assertTrue(l.get(0) instanceof java.lang.String);
    }

    public void testFactorySingleton() throws Exception {
        String foo1 = (String)PrimitiveFactory.getObject("string-object-foo");
        String foo2 = (String)PrimitiveFactory.getObject("string-object-foo");
        assertSame(foo1, foo2);
    }
    
    public void testMultiThreadedStartup() throws Exception {
        PrimitiveFactory.initFactory();
        for (int i = 0; i < 100; i++) {
            Thread tt = new TestGetObjectThread();
            tt.start();
        }
        Thread.sleep(1000);
        assertFalse(threadsFail);
    }
    
    public class TestGetObjectThread extends Thread {
      
        public void run() {
            try {
                Collection keys = PrimitiveFactory.getKeys();
                assertTrue(keys.size() == 3);
                String s = (String)PrimitiveFactory.getObject("string-object-foo");
                assertEquals("Foo", s);
            } 
            catch (ManifestFactoryLookupException mfle) {
                threadsFail = true;
                mfle.printStackTrace();
            }
        }
        
    }    
}
