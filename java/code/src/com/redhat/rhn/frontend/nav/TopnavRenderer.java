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

import com.redhat.rhn.frontend.html.HtmlTag;

import java.util.Map;

/**
 * TopnavRenderer renders the Navigation Tree as an unordered list.
 * Uses CSS to create tabbed view.
 * <pre>
 *     &lt;ul&gt;
 *         &lt;li id=\"mainFirst-active\"&gt;
 *         &lt;a href=\"http://rhn.redhat.com\"&gt;name&lt;/a&gt;
 *         &lt;/li&gt;
 *     &lt;/ul&gt;
 * </pre>
 * @version $Rev$
 */
public class TopnavRenderer extends Renderable {

    private HtmlTag ulTag;
    private boolean foundFirstNode = false;

    /**
     * Public constructor
     */
    public TopnavRenderer() {
        // empty
    }

    /** {@inheritDoc} */
    public void preNavLevel(StringBuffer sb, int depth) {
        if (!canRender(null, depth)) {
            return;
        }
        ulTag = new HtmlTag("ul");
        ulTag.setAttribute("id", "mainNav");
        sb.append(ulTag.renderOpenTag());
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
        if (canRender(node, depth)) {
            HtmlTag liTag = new HtmlTag("li");
            String classStr = "";
            if (node.isFirst() || !foundFirstNode) {
                liTag.setAttribute("id", "mainFirst-active");
                classStr = "mainFirstLink";
                foundFirstNode = true;
                
            }
            else if (node.isLast()) {
                liTag.setAttribute("id", "mainLast-active");
                classStr = "mainLastLink";
            }
            else {
                liTag.setAttribute("id", "main-active");
                // no class
            }
            liTag.addBody(getLink(node.getPrimaryURL(),
                                node.getName(), classStr, node.getTarget()));
            sb.append(liTag.render());
            sb.append("\n");
        }
    }

    /** {@inheritDoc} */
    public void navNodeInactive(StringBuffer sb,
                                NavNode node,
                                NavTreeIndex treeIndex,
                                Map parameters,
                                int depth) {
        
        if (canRender(node, depth)) {
            HtmlTag liTag = new HtmlTag("li");
            String classStr = "";
            if (node.isFirst() || !foundFirstNode) {
                liTag.setAttribute("id", "mainFirst");
                classStr = "mainFirstLink";
                foundFirstNode = true;
            }
            else if (node.isLast()) {
                liTag.setAttribute("id", "mainLast");
                classStr = "mainLastLink";
            }
            liTag.addBody(getLink(node.getPrimaryURL(),
                                node.getName(), classStr, node.getTarget()));
            sb.append(liTag.render());                                
            sb.append("\n");
        }
    }

    /** {@inheritDoc} */
    public void postNavNode(StringBuffer sb, int depth) {
    }

    /** {@inheritDoc} */
    public void postNavLevel(StringBuffer sb, int depth) {
        if (!canRender(null, depth)) {
            return;
        }
        sb.append(ulTag.renderCloseTag());
    }

    /** {@inheritDoc} */
    public boolean nodeRenderInline(int depth) {
        return true;
    }

    private String getLink(String url, String name, String classStr, String target) {
        HtmlTag a = new HtmlTag("a");
        a.setAttribute("href", url);
        if (classStr != null && !"".equals(classStr)) {
            a.setAttribute("class", classStr);
        }
        if (target != null && !"".equals(target)) {
            a.setAttribute("target", target);
        }
        a.addBody(name);

        return a.render();
    }

    /** {@inheritDoc} */
    public void preNav(StringBuffer sb) {
    }

    /** {@inheritDoc} */
    public void postNav(StringBuffer sb) {
    }
}
