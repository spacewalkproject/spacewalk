/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.satellite.search.index.builder.tests;

import com.redhat.satellite.search.index.builder.BuilderFactory;
import com.redhat.satellite.search.index.builder.DocumentBuilder;
import com.redhat.satellite.search.index.builder.ErrataDocumentBuilder;
import com.redhat.satellite.search.index.builder.PackageDocumentBuilder;
import com.redhat.satellite.search.index.builder.ServerDocumentBuilder;

import junit.framework.TestCase;


/**
 * BuilderFactoryTest
 * @version $Rev$
 */
public class BuilderFactoryTest extends TestCase {

    public void testGetBuilderErrataType() {
        DocumentBuilder db = BuilderFactory.getBuilder(BuilderFactory.ERRATA_TYPE);
        assertNotNull(db);
        assertEquals(db.getClass(), ErrataDocumentBuilder.class);
    }
    
    public void testGetBuilderPackageType() {
        DocumentBuilder db = BuilderFactory.getBuilder(BuilderFactory.PACKAGES_TYPE);
        assertNotNull(db);
        assertEquals(db.getClass(), PackageDocumentBuilder.class);
    }
    
    public void testGetBuilderServerType() {
        DocumentBuilder db = BuilderFactory.getBuilder(BuilderFactory.SERVER_TYPE);
        assertNotNull(db);
        assertEquals(db.getClass(), ServerDocumentBuilder.class);
    }
    
    public void testGetBuilderInvalid() {
        try {
            BuilderFactory.getBuilder(null);
            fail("getBuilder should have thrown exception with null type");
        }
        catch(UnsupportedOperationException uoe) {
            assertTrue(true);
        }
        
        try {
            BuilderFactory.getBuilder("foobar");
            fail("getBuilder should have thrown exception with null type");
        }
        catch(UnsupportedOperationException uoe) {
            assertTrue(true);
        }
    }

}
