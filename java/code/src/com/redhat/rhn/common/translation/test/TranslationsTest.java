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

package com.redhat.rhn.common.translation.test;

import com.redhat.rhn.common.translation.TranslationException;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

public class TranslationsTest extends RhnBaseTestCase {
    public void testNoTranslator() throws Exception {
        try {
            // Try a translation that should be impossible.  This should make
            // sure that nobody ever writes a translator to do this.
            TestTranslations.convert("hmmm", java.util.List.class); 
            fail("Shouldn't be able to translate from String to list");
        }
        catch (TranslationException e) {
            // Expected exception, shouldn't have a cause.
            assertNull(e.getCause()); 
        }
    }

    public void testlongDateTranslation() throws Exception {

        long current = System.currentTimeMillis();
        Date translated = (Date)TestTranslations.convert(new Long(current), 
                                                   java.util.Date.class); 
        assertEquals(new Date(current), translated);
    }

    public void testFailedTranslation() throws Exception {
        try {
            TestTranslations.convert("hmmm", java.lang.Integer.class); 
            fail("Translation should have failed");
        }
        catch (TranslationException e) {
            assertEquals(e.getCause().getClass(),
                         java.lang.NumberFormatException.class);
        }
    }

    public void testPrivateTranslator() throws Exception {
        try {
            TestTranslations.convert(new Integer(1), java.lang.Long.class); 
            fail("Translation should have failed");
        }
        catch (TranslationException e) {
            assertEquals(e.getCause().getClass(),
                         java.lang.IllegalAccessException.class);
        }
    }
    
    public void testListToString() {
        List list = new ArrayList();
        list.add(new Integer(10));
        list.add("list");
        String s = (String) TestTranslations.convert(list, String.class);
        assertNotNull(s);
        assertEquals("[10, list]", s);
        
        list = new LinkedList();
        list.add(new Integer(20));
        list.add("list");
        s = (String) TestTranslations.convert(list, String.class);
        assertNotNull(s);
        assertEquals("[20, list]", s);
    }
}
