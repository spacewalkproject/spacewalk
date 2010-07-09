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
package com.redhat.rhn.internal.doclet;

import com.sun.javadoc.RootDoc;

/**
 *
 * HtmlDoclet
 * @version $Rev$
 */
public class HtmlDoclet {

    private HtmlDoclet() {
    }

    /**
     * Starts the wiki doclet
     * @param root document root
     * @return true if success
     * @throws Exception e
     */
    public static boolean start(RootDoc root) throws Exception {

        return ApiDoclet.start(root, "html");
    }

}
