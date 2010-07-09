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
 * DialognavRenderer - renders a CSS
 * @version $Rev$
 */

public class DialognavRenderer extends Renderable {
    private StringBuffer titleBuf;
    /**
     * Public constructor
     */
    public DialognavRenderer() {
         // empty
        titleBuf = new StringBuffer();
    }

    /** {@inheritDoc} */
    public void preNav(StringBuffer sb) {
        HtmlTag div = new HtmlTag("div");
        div.setAttribute("class", "content-nav");
        sb.append(div.renderOpenTag());
    }

    /** {@inheritDoc} */
    public void preNavLevel(StringBuffer sb, int depth) {
        if (!canRender(null, depth)) {
            return;
        }

        if (depth == 1) {
            HtmlTag div = new HtmlTag("div");
            div.setAttribute("class", "contentnav-row2");
            sb.append(div.renderOpenTag());

            div = new HtmlTag("div");
            div.setAttribute("class", "top");
            // This doesn't make much sense, but we must render the open tag
            // and the close tag as two separate tags.  The top CSS renders
            // horribly wrong if this is rendered as just a single tag.
            sb.append(div.renderOpenTag());
            sb.append(div.renderCloseTag());

            div = new HtmlTag("div");
            div.setAttribute("class", "bottom");
            sb.append(div.renderOpenTag());
        }

        HtmlTag ul = new HtmlTag("ul");
        ul.setAttribute("class", getRowClass(depth));
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

        titleBuf.append(" - " + node.getName());

        renderNode(sb, node, treeIndex, parameters,
                   "content-nav-selected", "content-nav-selected-link");
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

        renderNode(sb, node, treeIndex, parameters, "", "");
    }

    private void renderNode(StringBuffer sb, NavNode node,
                            NavTreeIndex treeIndex, Map parameters,
                            String cssClass, String cssLinkClass) {
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

        li.addBody(aHref(href, node.getName(), cssLinkClass, node.getTarget()));
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
        sb.append(ul.renderCloseTag());
        sb.append("\n");

        if (depth == 1) {
            HtmlTag div = new HtmlTag("div");
            sb.append(div.renderCloseTag());
            sb.append(div.renderCloseTag());
        }
    }

    /** {@inheritDoc} */
    public void postNav(StringBuffer sb) {
        HtmlTag div = new HtmlTag("div");
        sb.append(div.renderCloseTag());
        sb.append("\n");
    }

    /** {@inheritDoc} */
    public boolean nodeRenderInline(int depth) {
        return false;
    }

    private static String aHref(String url, String text, String style, String target) {
        HtmlTag a = new HtmlTag("a");
        if (style != null && !style.equals("")) {
            a.setAttribute("class", style);
        }

        if (target != null && !target.equals("")) {
            a.setAttribute("target", target);
        }

        a.setAttribute("href", url);
        a.addBody(text);
        return a.render();
    }

    private static String getRowClass(int depth) {
        if (depth == 0) {
            return "content-nav-rowone";
        }
        else if (depth == 1) {
            return "content-nav-rowtwo";
        }
        else {
            return "content-nav-rowthree";
        }
    }
}


