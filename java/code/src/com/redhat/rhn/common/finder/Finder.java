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

import java.util.List;

/**
 * An interface to find classes that implement a given interface.
 *
 * @version $Rev$
 */
public interface Finder {

    /**
     * Find all files within a package that end with the specified string.
     * In the future, this could be extended to use a regex of class
     * hierarchy to determine what belongs in the list.
     * @param endStr The string to match the files against.
     * @return a list of all classes within the package that end with the
     *         specified string
     */
    List find(String endStr);

    /**
     * Find all files within a package that end with the specified string
     * and don't begin with the exluding string
     * @param excluding The string to match the files against.
     * @param endStr The string to match the files against.
     * @return a list of all classes within the package that end with the
     *         specified string
     */
    List findExcluding(String[] excluding, String endStr);
}
