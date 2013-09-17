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
import java.util.StringTokenizer;

/**
 * DialognavRenderer - renders a navigation bar
 *
 * Renders the navigation inside the content, which is implemented
 * as rows of Twitter Bootstrap tabs (nav-tabs)
 *
 * The navigation is enclosed in a div styled with class
 * 'spacewalk-content-nav' and the individual rows can be styled by
 * ul:nth-child selectors.
 *
 * @version $Rev$
 */

public class DialognavRenderer extends Renderable {
    private final StringBuffer titleBuf;
    /**
     * Public constructor
     */
    public DialognavRenderer() {
         // empty
        titleBuf = new StringBuffer();
    }

    /** {@inheritDoc} */
    @Override
    public void preNav(StringBuffer sb) {
        HtmlTag div = new HtmlTag("div");
        div.setAttribute("class", "spacewalk-content-nav");
        sb.append(div.renderOpenTag());
    }

    /** {@inheritDoc} */
    @Override
    public void preNavLevel(StringBuffer sb, int depth) {
        if (!canRender(null, depth)) {
            return;
        }

        HtmlTag ul = new HtmlTag("ul");
        ul.setAttribute("class", "nav nav-tabs");
        sb.append(ul.renderOpenTag());
    }

    /** {@inheritDoc} */
    @Override
    public void preNavNode(StringBuffer sb, int depth) {
    }

    /** {@inheritDoc} */
    @Override
    public void navNodeActive(StringBuffer sb,
                              NavNode node,
                              NavTreeIndex treeIndex,
                              Map parameters,
                              int depth) {
        if (!canRender(node, depth)) {
            return;
        }

        titleBuf.append(" - " + node.getName());

        renderNode(sb, node, treeIndex, parameters,
                   "active");
    }

    /** {@inheritDoc} */
    @Override
    public void navNodeInactive(StringBuffer sb,
                                NavNode node,
                                NavTreeIndex treeIndex,
                                Map parameters,
                                int depth) {
        if (!canRender(node, depth)) {
            return;
        }

        renderNode(sb, node, treeIndex, parameters, "");
    }

    private void renderNode(StringBuffer sb, NavNode node,
                            NavTreeIndex treeIndex, Map parameters,
                            String cssClass) {
        HtmlTag li = new HtmlTag("li");

        if (!cssClass.equals("")) {
            li.setAttribute("class", cssClass);
        }

        String href = node.getPrimaryURL();
        String allowedFormVars = treeIndex.getTree().getFormvar();
        if (allowedFormVars != null) {
            StringBuffer formVars;
            if (href.indexOf("?") == -1) {
                formVars = new StringBuffer("?");
            }
            else {
                formVars = new StringBuffer("&");
            }

            StringTokenizer st = new StringTokenizer(allowedFormVars);
            while (st.hasMoreTokens()) {
                if (formVars.length() > 1) {
                    formVars.append("&amp;");
                }
                String currentVar = st.nextToken();
                String[] values = (String[])parameters.get(currentVar);

                // if currentVar is null, values will be null too, so we can
                // just check values.
                if (values != null) {
                    formVars.append(currentVar + "=" + values[0]);
                }
            }
            href += formVars.toString();
        }

        li.addBody(aHref(href, node.getName(), node.getTarget()));
        sb.append(li.render());
        sb.append("\n");
    }

    /** {@inheritDoc} */
    @Override
    public void postNavNode(StringBuffer sb, int depth) {
    }

    /** {@inheritDoc} */
    @Override
    public void postNavLevel(StringBuffer sb, int depth) {
        if (!canRender(null, depth)) {
            return;
        }

        HtmlTag ul = new HtmlTag("ul");
        sb.append(ul.renderCloseTag());
        sb.append("\n");
    }

    /** {@inheritDoc} */
    @Override
    public void postNav(StringBuffer sb) {
        HtmlTag div = new HtmlTag("div");
        sb.append(div.renderCloseTag());
        sb.append("\n");
    }

    /** {@inheritDoc} */
    @Override
    public boolean nodeRenderInline(int depth) {
        return false;
    }

    private static String aHref(String url, String text, String target) {
        HtmlTag a = new HtmlTag("a");

        if (target != null && !target.equals("")) {
            a.setAttribute("target", target);
        }

        a.setAttribute("href", url);
        a.addBody(text);
        return a.render();
    }
}


