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

/**
 * DepthGuard, a RenderGuard that watches for depth
 * @version $Rev$
 */

public class DepthGuard implements RenderGuard {
    private int minDepth;
    private int maxDepth;

    /**
     * Public constructor
     * @param minDepthIn the minimum render depth
     * @param maxDepthIn the maximum render depth
     */
    public DepthGuard(int minDepthIn, int maxDepthIn) {
        minDepth = minDepthIn;
        maxDepth = maxDepthIn;        
    }

    /**
     * Returns true if we are allowed to render at the given depth.
     * @param depth depth in the tree to determine if it is renderable.
     * @return true if we are allowed to render at the given depth.
     */
    public boolean canRender(int depth) {
        if (depth < minDepth || depth > maxDepth) {
            return false;
        }

        return true;
    }

    /** {@inheritDoc} */
    public boolean canRender(NavNode node, int depth) {
        return canRender(depth);
    }
}
