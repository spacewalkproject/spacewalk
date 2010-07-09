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

import org.apache.commons.digester.Digester;

import java.net.URL;

/**
 * Helper class to parse a sitenav.xml file, returning the tree
 * @version $Rev$
 */
public class NavDigester {
    // no contruction, please
    private NavDigester() { }

    /**
     * buildTree, method to take a url and parse the contents
     * into a NavTree
     * @param url the file to parse
     * @return NavTree the tree represented by the file
     * @throws Exception if something breaks. XXX: fix to be tighter
     */
    public static NavTree buildTree(URL url) throws Exception {
        if (url == null) {
            throw new IllegalArgumentException("URL is null, your definition tag " +
                    "probably points to a non existing file.");
        }
        Digester digester = new Digester();
        digester.setValidating(false);

        digester.addObjectCreate("rhn-navi-tree", NavTree.class);
        digester.addSetProperties("rhn-navi-tree");
        digester.addSetProperties("rhn-navi-tree",
                                  "acl_mixins",
                                  "aclMixins");

        digester.addObjectCreate("*/rhn-tab", NavNode.class);
        digester.addSetProperties("*/rhn-tab",
                                  "active-image",
                                  "activeImage");
        digester.addSetProperties("*/rhn-tab",
                                  "inactive-image",
                                  "inactiveImage");
        digester.addSetProperties("*/rhn-tab",
                                  "target",
                                  "target");

        digester.addCallMethod("*/rhn-tab",
                               "addPrimaryURL",
                               1);
        digester.addCallParam("*/rhn-tab",
                              0,
                              "url");

        digester.addCallMethod("*/rhn-tab/rhn-tab-url",
                               "addURL",
                               0);
        digester.addCallMethod("*/rhn-tab/rhn-tab-directory",
                               "addDirectory",
                               0);

        digester.addSetNext("*/rhn-tab", "addNode");
        return (NavTree)digester.parse(url.openStream());
    }
}


