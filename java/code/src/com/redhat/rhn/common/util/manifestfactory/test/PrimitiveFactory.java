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

import com.redhat.rhn.common.util.manifestfactory.ManifestFactory;

import java.util.Collection;

/**
 * PrimitiveFactory, a ManifestFactory based fatory for creating
 * primitive types of things.  used in testcase.
 *
 * @version $Rev$
 */

public class PrimitiveFactory {
    private static PrimitiveBuilder builder;
    private static ManifestFactory factory;

    /** private constructor */
    private PrimitiveFactory() {
    }

    public static Object getObject(String name) {
        if (factory == null || builder == null) {
            initFactory();
        }
        return factory.getObject(name);
    }

    public static Collection getKeys() {
        if (factory == null || builder == null) {
            initFactory();
        }
        return factory.getKeys();
    }

    /** So we can test re-parsing the manifest */
    public static void initFactory() {
        builder = new PrimitiveBuilder();
        factory = new ManifestFactory(builder);
    }
}
