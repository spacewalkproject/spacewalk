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
 * Renderable - base class for rendering
 * @version $Rev$
 */
public abstract class Renderable {
    private RenderGuard guard;

    /**
     * called before the nav is rendered
     * @param sb string buffer to append to
     */
    public abstract void preNav(StringBuffer sb);

    /**
     * called before a nav level is rendered
     * @param sb string buffer to append to
     * @param depth current depth of rendering
     */
    public abstract void preNavLevel(StringBuffer sb, int depth);

    /**
     * called before a nav node is rendered
     * @param sb string buffer to append to
     * @param depth current depth of rendering
     */
    public abstract void preNavNode(StringBuffer sb, int depth);

    /**
     * called to render an active node (ie, one that should be
     * highlighted)
     *
     * @param sb string buffer to append to
     * @param node the node being rendered
     * @param treeIndex the index for the tree we are insde of
     * @param parameters name value pair of generic parameters for the node.
     * @param depth the current render depth
     */
    public abstract void navNodeActive(StringBuffer sb,
                       NavNode node,
                       NavTreeIndex treeIndex,
                       Map parameters,
                       int depth);

    /**
     * called to render an active node (ie, one that should not be
     * highlighted)
     *
     * @param sb string buffer to append to
     * @param node the node being rendered
     * @param treeIndex the index for the tree we are insde of
     * @param parameters name value pair of generic parameters for the node.
     * @param depth the current render depth
     */
    public abstract void navNodeInactive(StringBuffer sb,
                         NavNode node,
                         NavTreeIndex treeIndex,
                         Map parameters,
                         int depth);

    /**
     * called after a nav node is rendered
     * @param sb string buffer to append to
     * @param depth current depth of rendering
     */
    public abstract void postNavNode(StringBuffer sb, int depth);

    /**
     * called after a nav level is rendered
     * @param sb string buffer to append to
     * @param depth current depth of rendering
     */
    public abstract void postNavLevel(StringBuffer sb, int depth);

    /**
     * called after the full nav is rendered
     * @param sb string buffer to append to
     */
    public abstract void postNav(StringBuffer sb);

    /**
     * returns true if a child node should render inline with its
     * parent (like leftnav) vs rendering after all the current node's
     * siblins (like the dialog tabbed nav)
     * @param depth the depth of the current node
     * @return boolean if to render inline
     */

    public abstract boolean nodeRenderInline(int depth);

    /**
     * sets the RenderGuard for this Renderable
     * @param guardIn the guardian
     */
    public final void setRenderGuard(RenderGuard guardIn) {
        this.guard = guardIn;
    }

    /**
     * checn to see if a given node element at a given depth can be
     * rendered
     * @param node the node in question
     * @param depth the depth in question
     * @return boolean whether the node should be rendered or not
     */
    protected final boolean canRender(NavNode node, int depth) {
        if (guard != null) {
            return guard.canRender(node, depth) && guard.canRender(node, depth);
        }

        return true;
    }
}


