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

import java.util.Map;

/**
 * TitleRenderer renders each active Node in the Navigation Tree
 * separated by a dash "-".  The resulting string is used as
 * the title of the page, which makes it easy to see how you
 * navigated through the site.
 * @version $Rev$
 */

public class TitleRenderer extends Renderable {
    /**
     * Public constructor
     */
    public TitleRenderer() {
        // empty
    }

    /** {@inheritDoc} */
    public void preNavLevel(StringBuffer sb, int depth) {
    }

    /** {@inheritDoc} */
    public void preNavNode(StringBuffer sb, int depth) {
    }

    /** {@inheritDoc} */
    public void navNodeActive(StringBuffer sb,
                              NavNode node,
                              NavTreeIndex treeIndex,
                              Map parameters,
                              int depth) {
        if (!canRender(node, depth)) {
            return;
        }

        sb.append(" - " + node.getName());
    }

    /** {@inheritDoc} */
    public void navNodeInactive(StringBuffer sb,
                                NavNode node,
                                NavTreeIndex treeIndex,
                                Map parameters,
                                int depth) {
        return;
    }

    /** {@inheritDoc} */
    public void postNavNode(StringBuffer sb, int depth) {
    }

    /** {@inheritDoc} */
    public void postNavLevel(StringBuffer sb, int depth) {
    }

    /** {@inheritDoc} */
    public boolean nodeRenderInline(int depth) {
        return true;
    }

    /** {@inheritDoc} */
    public void preNav(StringBuffer sb) {
    }

    /** {@inheritDoc} */
    public void postNav(StringBuffer sb) {
    }
}


