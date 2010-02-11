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

package com.redhat.rhn.frontend.nav;

import java.net.URL;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/**
 * NavCache, a simple cache that will prevent us from reparsing the
 * same nav xml file over and over.  Operates 'dumbly' right now,
 * which is to basically cache a given lookup forever.
 *
 * @version $Rev$
 */

public class NavCache {
    // the cache itself; a nice, happy, synchronized map
    private static Map cache = Collections.synchronizedMap(new HashMap());

    /** Private constructor, this is a utility cass  */
    private NavCache() {
    }

    /**
     * Returns a tree for the given URL, constructing it if necessary.
     * @param url URL whose section of the tree is desired.
     * @return tree for the given URL
     * @throws Exception if an error occurs building the tree.
     */
    public static NavTree getTree(URL url) throws Exception {
        NavTree ret = (NavTree)cache.get(url);

        if (ret != null) {
            return ret;
        }

        ret = NavDigester.buildTree(url);
        cache.put(url, ret);

        return ret;
    }
}
