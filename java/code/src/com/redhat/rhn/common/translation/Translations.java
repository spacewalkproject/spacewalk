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

package com.redhat.rhn.common.translation;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * TranslationFactory, simple factory class that uses ManifestFactory to
 * return translation methods
 *
 * @version $Rev$
 */

public class Translations {

    protected Translations() {
    }

    // This is a HACK!  Basically, we can't get to the Class object from
    // within a static method.  So, we pass the Class object in from
    // a sub-class.
    protected static Object convert(Class thisClass, Object have, Class want) {

        // Don't worry about classes that are assignable; i.e., HashMap -> Map
        if (want.isAssignableFrom(have.getClass())) {
            return have;
        }

        Method[] methods = thisClass.getDeclaredMethods();

        // tries to find an exact match
        Object rc = findMatch(methods, have, want, false);

        if (rc == null) {
            // try to find the best match
            rc = findMatch(methods, have, want, true);

            if (rc == null) {
                throw new TranslationException("Could not find translator for " +
                        have.getClass() + " to " + want);
            }
        }

        return rc;
    }

    private static Object findMatch(Method[] methods, Object have,
                                    Class want, boolean bestMatch)
            throws TranslationException {

        for (int i = 0; i < methods.length; i++) {
            Class returnType = methods[i].getReturnType();
            Class[] params = methods[i].getParameterTypes();

            // All conversions have a single parameter, the object to transform
            if (!bestMatch && have != null &&
                (params.length != 1 || !params[0].equals(have.getClass()))) {
                continue;
            }
            else if (bestMatch && have != null &&
                    (params.length != 1 || !params[0].isAssignableFrom(have.getClass()))) {
                continue;
            }

            if (returnType.equals(want)) {
                Object[] objs = {have};
                try {
                    return methods[i].invoke(null, objs);
                }
                catch (IllegalAccessException e) {
                    throw new TranslationException("Could not execute " +
                                    "translator for " + have.getClass() +
                                    " to " + want, e);
                }
                catch (InvocationTargetException e) {
                    throw new TranslationException("Error when executing " +
                                    "translator for " + have.getClass() +
                                    " to " + want, e.getCause());
                }
            }
        }

        return null;
    }
}
