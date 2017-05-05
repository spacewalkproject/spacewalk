/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static java.util.stream.Collectors.joining;
import static java.util.stream.Stream.concat;
import static java.util.stream.Stream.empty;
import static java.util.stream.Stream.of;
import static org.apache.commons.lang3.StringUtils.isNotEmpty;

/**
 * SidenavRenderer renders an unordered list which is decorated
 * using CSS. Each active list item has a predefined class named
 * sidenav-selected.
 * <pre>
 * &lt;ul&gt;
 *     &lt;li class=\"sidenav-selected\"&gt;
 *     &lt;a href=\"url\"&gt;name&lt;/a&gt;&lt;/lt&gt;
 * &lt;/ul&gt;
 * </pre>
 * @version $Rev$
 */

public class SidenavRenderer extends Renderable {
    /**
     * Public constructor
     */
    public SidenavRenderer() {
        // empty
    }

    /** {@inheritDoc} */
    public void preNavLevel(StringBuffer sb, int depth) {
        if (!canRender(null, depth)) {
            return;
        }
        if (depth > 1) {
            HtmlTag li = new HtmlTag("li");
            sb.append(li.renderOpenTag() + '\n');
        }

        HtmlTag ul = new HtmlTag("ul");
        ul.setAttribute("class", "nav nav-pills nav-stacked");
        sb.append(ul.renderOpenTag());
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

        renderNode(sb, node, Stream.of("active"));
    }

    /** {@inheritDoc} */
    public void navNodeInactive(StringBuffer sb,
                                NavNode node,
                                NavTreeIndex treeIndex,
                                Map parameters,
                                int depth) {
        if (!canRender(node, depth)) {
            return;
        }

        this.renderNode(sb, node, Stream.empty());
    }

    private void renderNode(StringBuffer sb, NavNode node, Stream<String> baseClasses) {
        HtmlTag li = new HtmlTag("li");

        Stream<String> additionalClasses =
                node.getNodes().isEmpty() ? empty() : of("parent");
        String classString = concat(baseClasses, additionalClasses).collect(joining(" "));

        if (isNotEmpty(classString)) {
            li.setAttribute("class", classString);
        }

        li.addBody(aHref(node.getPrimaryURL(), node.getName(), node.getTarget()));
        sb.append(li.render());
        sb.append("\n");
    }

    /** {@inheritDoc} */
    public void postNavNode(StringBuffer sb, int depth) {
    }

    /** {@inheritDoc} */
    public void postNavLevel(StringBuffer sb, int depth) {
        if (!canRender(null, depth)) {
            return;
        }

        HtmlTag ul = new HtmlTag("ul");
        sb.append(ul.renderCloseTag() + "\n");

        if (depth > 1) {
            HtmlTag li = new HtmlTag("li");
            sb.append(li.renderCloseTag() + '\n');
        }
    }

    /** {@inheritDoc} */
    public boolean nodeRenderInline(int depth) {
        return true;
    }

    private static String aHref(String url, String text, String target) {
        HtmlTag a = new HtmlTag("a");
        a.setAttribute("href", url);
        if (target != null && !target.equals("")) {
            a.setAttribute("target", target);
        }
        a.addBody(text);
        return a.render();
    }

    /** {@inheritDoc} */
    public void preNav(StringBuffer sb) {
    }

    /** {@inheritDoc} */
    public void postNav(StringBuffer sb) {
    }
}
