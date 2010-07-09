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

package com.redhat.rhn.common.finder;

import java.io.File;
import java.net.URL;

/**
 * A factory that returns the correct type of finder.
 *
 * @version $Rev$
 */
public class FinderFactory {

    private FinderFactory() {
    }

    /**
     * Return the correct finder for finding classes in the given package.
     * @param packageName Name of package to be searched.
     * @return Finder to use for given package name.
     */
    public static Finder getFinder(String packageName) {
        // Start by translating into an absolute path.
        String name = packageName;
        if (!packageName.startsWith("/")) {
            name = "/" + name;
        }
        name = name.replace('.', '/');

        URL packageUrl = FinderFactory.class.getResource(name);

        // This only happens if the .jar file isn't well-formed, so we
        // shouldn't have this problem, ever.
        if (packageUrl == null) {
            throw new IllegalArgumentException("Not a well formed jar file");
        }

        File directory = new File(packageUrl.getFile());

        if (!directory.isFile() && !directory.isDirectory()) {
            // This is a jar file that we are dealing with.
            return new JarFinder(packageUrl);
        }
        return new FileFinder(directory, name);
    }
}
