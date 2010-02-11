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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * RenderGuardComposite
 * @version $Rev$
 */
public class RenderGuardComposite implements RenderGuard {

    private List guards;

    /**
     * Constructor
     */
    public RenderGuardComposite() {
        super();
        guards = new ArrayList();
    }

    /**
     * Returns true if all renderers return true or no renderers are configured.
     * @param node Node to be checked.
     * @param depth Depth of node.
     * @return true if all renderers return true or no renderers are configured.
     */
    public boolean canRender(NavNode node, int depth) {
        boolean flag = true;

        for (Iterator itr = guards.iterator(); itr.hasNext() && flag;) {
            RenderGuard guard = (RenderGuard) itr.next();
            if (guard != null) {
                flag = guard.canRender(node, depth);
            }
        }

        return flag;
    }

    /**
     * Adds a RenderGuard to the composite.
     * @param guard RenderGuard to be added to this composite.
     */
    public void addRenderGuard(RenderGuard guard) {
        guards.add(guard);
    }
}
