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

import com.redhat.rhn.common.ObjectCreateWrapperException;
import com.redhat.rhn.common.util.manifestfactory.ClassBuilder;

import java.util.HashMap;
import java.util.Map;

import junit.framework.TestCase;


public class ClassBuilderTest extends TestCase {

    private ClassBuilder builder;

    public void setUp() {
        builder = new ClassBuilder(null, "testclass-manifest.xml");
    }
    public void testCreateObject() {
        Map params = new HashMap();
        params.put("classname", "java.lang.String");
        Object s = builder.createObject(params);
        assertNotNull(s);
        assertEquals(String.class, s.getClass());
    }

    public void testNullClassname() {
        Map params = new HashMap();
        params.put("classname", null);
        try {
            builder.createObject(params);
            fail("expected a nullpointer exception");
        }
        catch (NullPointerException npe) {
            // expected exception
        }
    }

    public void testCreationException() {
        Map params = new HashMap();
        params.put("classname", "bet.you.cant.find.Me");
        try {
            builder.createObject(params);
            fail("expected an objectcreatewrapperexception");
        }
        catch (ObjectCreateWrapperException ocwe) {
            // expected exception
        }
    }

    public void testManifestFilename() {
        assertEquals("/testclass-manifest.xml", builder.getManifestFilename());
    }
}
