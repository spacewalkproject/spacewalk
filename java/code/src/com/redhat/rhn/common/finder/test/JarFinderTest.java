/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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

package com.redhat.rhn.common.finder.test;
import com.redhat.rhn.common.finder.Finder;
import com.redhat.rhn.common.finder.FinderFactory;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.List;

public class JarFinderTest extends RhnBaseTestCase {

    // NOTE: Test is dependent on knowing things like "How many classes are in jarfile X"
    // When "X" changes, the test FAILS.
    // Sigh.
    // At least make it clear what we're looking for...

    // As of this writing, java/rhnwebapp/WEB-INF/lib/redstone-xmlrpc-1.1_20071120.jar
    private static final String TESTJAR = "redstone.xmlrpc";
    private static final int NUM_CLASSES_IN_TESTJAR = 46;
    private static final int NUM_SUBDIRS_IN_TESTJAR = 47;

    public void testGetFinder() throws Exception {
        Finder f = FinderFactory.getFinder(TESTJAR);
        assertNotNull(f);
    }

    public void testFindFiles() throws Exception {
        Finder f = FinderFactory.getFinder(TESTJAR);
        assertNotNull(f);

        List<String> result = f.find(".class");
        assertEquals(NUM_CLASSES_IN_TESTJAR, result.size());
    }

    public void testFindFilesSubDir() throws Exception {
        Finder f = FinderFactory.getFinder(TESTJAR);
        assertNotNull(f);

        List<String> result = f.find("");
        assertEquals(NUM_SUBDIRS_IN_TESTJAR, result.size());
    }

    public void testFindFilesExcluding() throws Exception {
        Finder f = FinderFactory.getFinder(TESTJAR);
        assertNotNull(f);

        String[] sarr = {"End"};

        List<String> result = f.findExcluding(sarr, "class");
        assertEquals(NUM_CLASSES_IN_TESTJAR, result.size());
    }
}


