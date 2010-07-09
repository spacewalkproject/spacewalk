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

import java.util.List;
import java.util.Map;

/**
 * RenderEngine
 * @version $Rev$
 */

public class RenderEngine {
    private NavTreeIndex treeIndex;
    private StringBuffer result;

    /**
     * public constructor
     * @param treeIndexIn the index for the tree we are rendering
     */
    public RenderEngine(NavTreeIndex treeIndexIn) {
        treeIndex = treeIndexIn;
    }

    /**
     * actually render the tree, given a render interface implementation
     * @param renderer the render interface
     * @return the rendered nav
     */
    public String render(Renderable renderer) {
        return render(renderer, null);
    }

    /**
     * actually render the tree, given a render interface implementation
     * @param renderer the render interface
     * @param parameters Any request parameters to add to links as they are rendered.
     * @return the rendered nav
     */
    public String render(Renderable renderer, Map parameters) {
        result = new StringBuffer();
        List todo = treeIndex.getTree().getNodes();

        renderer.preNav(result);
        this.renderLevel(renderer, todo, parameters, 0);
        renderer.postNav(result);

        return result.toString();
    }

    private void renderLevel(Renderable renderer, List todo,
                             Map parameters, int depth) {
        if (todo == null || todo.size() == 0) {
            return;
        }

        renderer.preNavLevel(result, depth);

        NavNode activeNode = null;

        int size = todo.size();
        for (int i = 0; i < size; i++) {
            NavNode node = (NavNode) todo.get(i);

            // mark the nodes as first or last based on index.
            if (i == 0) {
                node.setFirst(true);
            }
            else if (i == (size - 1)) {
                node.setLast(true);
            }

            renderer.preNavNode(this.result, depth);

            if (treeIndex.isNodeActive(node)) {
                renderer.navNodeActive(result, node, treeIndex, parameters, depth);
                activeNode = node;
                if (renderer.nodeRenderInline(depth)) {
                    renderLevel(renderer, node.getNodes(), parameters, depth + 1);
                }
            }
            else {
                renderer.navNodeInactive(result, node, treeIndex, parameters, depth);
            }

            renderer.postNavNode(this.result, depth);
        }


        renderer.postNavLevel(result, depth);

        if (activeNode != null && !renderer.nodeRenderInline(depth)) {
            renderLevel(renderer, activeNode.getNodes(), parameters, depth + 1);
        }
    }
}


