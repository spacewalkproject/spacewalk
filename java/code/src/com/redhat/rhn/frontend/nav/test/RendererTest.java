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
package com.redhat.rhn.frontend.nav.test;

import com.redhat.rhn.frontend.nav.DialognavRenderer;
import com.redhat.rhn.frontend.nav.NavNode;
import com.redhat.rhn.frontend.nav.NavTree;
import com.redhat.rhn.frontend.nav.NavTreeIndex;
import com.redhat.rhn.frontend.nav.RenderGuard;
import com.redhat.rhn.frontend.nav.Renderable;
import com.redhat.rhn.frontend.nav.SidenavRenderer;
import com.redhat.rhn.frontend.nav.TextRenderer;
import com.redhat.rhn.frontend.nav.TopnavRenderer;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.HashMap;
import java.util.Map;

/**
 * RendererTest tests all Renderable classes.
 * @version $Rev$
 */
public class RendererTest extends RhnBaseTestCase {

    ////////////////////////////////////////////////////////////////
    // TEST: DialognavRenderer
    ////////////////////////////////////////////////////////////////

    public void testDialognavTrue() {
        Map expectations = new HashMap();
        expectations.put("preNavLevel",
                         "<ul class=\"content-nav-rowthree\">");
        expectations.put("preNavNode", "");
        expectations.put("navNodeActive",
                         "<li class=\"content-nav-selected\"><a " +
                         "class=\"content-nav-selected-link\" " +
                         "href=\"http://rhn.redhat.com\">name</a></li>\n");
        expectations.put("navNodeInactive",
                         "<li><a href=\"http://rhn.redhat.com\">name</a></li>\n");
        expectations.put("postNavNode", "");
        expectations.put("postNavLevel", "</ul>\n");
        expectations.put("nodeRenderInline", Boolean.FALSE);

        // test depth > 1
        rendererTest(new DialognavRenderer(), new TrueRenderGuard(), expectations, 4);

        // test depth 1
        expectations.put("preNavLevel", "<div class=\"contentnav-row2\">" +
                         "<div class=\"top\"></div><div class=\"bottom\">" +
                         "<ul class=\"content-nav-rowtwo\">");
        expectations.put("postNavLevel", "</ul>\n</div></div>");
        rendererTest(new DialognavRenderer(), new TrueRenderGuard(), expectations, 1);

        // test depth 0
        expectations.put("preNavLevel",
                         "<ul class=\"content-nav-rowone\">");
        expectations.put("postNavLevel", "</ul>\n");
        rendererTest(new DialognavRenderer(), new TrueRenderGuard(), expectations, 0);
    }

    public void testDialognavFalse() {
        Map expectations = new HashMap();
        expectations.put("preNavLevel", "");
        expectations.put("preNavNode", "");
        expectations.put("navNodeActive", "");
        expectations.put("navNodeInactive", "");
        expectations.put("postNavNode", "");
        expectations.put("postNavLevel", "");
        expectations.put("nodeRenderInline", Boolean.FALSE);

        rendererTest(new DialognavRenderer(), new FalseRenderGuard(), expectations, 0);
    }

    ////////////////////////////////////////////////////////////////
    // TEST: TextRenderer
    ////////////////////////////////////////////////////////////////

    public void testTextTrue() {
        Map expectations = new HashMap();
        expectations.put("preNavLevel", "");
        expectations.put("preNavNode", "        ");

        NavNode node = forgeNavNode();
        expectations.put("navNodeActive",
                         "(*) Node 'name': http://rhn.redhat.com [acl: acl] " +
                         node.hashCode() + "\n");
        expectations.put("navNodeInactive",
                         "( ) Node 'name': http://rhn.redhat.com [acl: acl] " +
                         node.hashCode() + "\n");

        expectations.put("postNavNode", "");
        expectations.put("postNavLevel", "");
        expectations.put("nodeRenderInline", Boolean.TRUE);

        rendererTest(new TextRenderer(), node, new TrueRenderGuard(), expectations, 4);
    }

    public void testTextFalse() {
        Map expectations = new HashMap();
        expectations.put("preNavLevel", "");
        expectations.put("preNavNode", "");
        expectations.put("navNodeActive", "");
        expectations.put("navNodeInactive", "");
        expectations.put("postNavNode", "");
        expectations.put("postNavLevel", "");
        expectations.put("nodeRenderInline", Boolean.TRUE);

        rendererTest(new TextRenderer(), new FalseRenderGuard(), expectations, 4);
    }

    ////////////////////////////////////////////////////////////////
    // TEST: TopnavRenderer
    ////////////////////////////////////////////////////////////////

    public void testTopnavTrue() {
        Map expectations = new HashMap();
        expectations.put("preNavLevel", "<ul id=\"mainNav\">");
        expectations.put("preNavNode", "");
        expectations.put("navNodeActive",
                         "<li id=\"mainFirst-active\">" +
                         "<a href=\"http://rhn.redhat.com\" class=" +
                         "\"mainFirstLink\">name</a></li>\n");
        expectations.put("navNodeInactive",
                         "<li><a href=\"http://rhn.redhat.com\">name</a></li>\n");
        expectations.put("postNavNode", "");
        expectations.put("postNavLevel", "</ul>");
        expectations.put("nodeRenderInline", Boolean.TRUE);

        rendererTest(new TopnavRenderer(), new TrueRenderGuard(), expectations, 4);
    }

    public void testTopnavFalse() {
        Map expectations = new HashMap();
        expectations.put("preNavLevel", "");
        expectations.put("preNavNode", "");
        expectations.put("navNodeActive", "");
        expectations.put("navNodeInactive", "");
        expectations.put("postNavNode", "");
        expectations.put("postNavLevel", "");
        expectations.put("nodeRenderInline", Boolean.TRUE);

        rendererTest(new TopnavRenderer(), new FalseRenderGuard(), expectations, 4);
    }

    public void testTopnavBug187800() {

        TopnavRenderer tr = new TopnavRenderer();
        StringBuffer buf = new StringBuffer();
        NavNode node1 = new NavNode();
        node1.addURL("/newlogin/index.pxt");
        node1.setName("Sign In");
        node1.setFirst(true);

        NavNode node2 = new NavNode();
        node2.addURL("/newlogin/index.pxt");
        node2.setName("About Spacewalk");
        node2.setLast(true);

        // test the case where active node runs first
        tr.navNodeActive(buf, node1, null, null, 4);
        tr.navNodeInactive(buf, node2, null, null, 4);

        String expectation = "<li id=\"mainFirst-active\"><a href=\"" +
               "/newlogin/index.pxt\" class=\"mainFirstLink\">" +
               "Sign In</a></li>\n<li id=\"mainLast\"><a href=\"" +
               "/newlogin/index.pxt\" class=\"mainLastLink\">About</a></li>\n";
        assertEquals(expectation, buf.toString());

        // test the case where inactive node runs first
        buf = new StringBuffer();
        tr.navNodeInactive(buf, node1, null, null, 4);
        tr.navNodeActive(buf, node2, null, null, 4);

        String expectation2 = "<li id=\"mainFirst\">" +
        "<a href=\"/newlogin/index.pxt\" class=\"mainFirstLink\">Sign In</a>" +
        "</li>\n" +
        "<li id=\"mainLast-active\"><a href=\"/newlogin/index.pxt\" " +
        "class=\"mainLastLink\">About</a>" +
        "</li>\n";
        assertEquals(expectation2, buf.toString());
    }

    ////////////////////////////////////////////////////////////////
    // TEST: SidenavRenderer
    ////////////////////////////////////////////////////////////////

    public void testSidenavTrue() {
        Map expectations = new HashMap();
        expectations.put("preNavLevel", "<ul>");
        expectations.put("preNavNode", "");
        expectations.put("navNodeActive", "<li class=\"sidenav-selected navparent\">" +
                         "<a href=\"http://rhn.redhat.com\">name</a></li>\n");
        expectations.put("navNodeInactive",
                         "<li class=\"navparent\"><a href=\"http://rhn.redhat.com\">" +
                         "name</a></li>\n");
        expectations.put("postNavNode", "");
        expectations.put("postNavLevel", "</ul>\n");
        expectations.put("nodeRenderInline", Boolean.TRUE);

        rendererTest(new SidenavRenderer(), new TrueRenderGuard(), expectations, 1);
    }

    public void testSidenavFalse() {
        Map expectations = new HashMap();
        expectations.put("preNavLevel", "");
        expectations.put("preNavNode", "");
        expectations.put("navNodeActive", "");
        expectations.put("navNodeInactive", "");
        expectations.put("postNavNode", "");
        expectations.put("postNavLevel", "");
        expectations.put("nodeRenderInline", Boolean.TRUE);

        rendererTest(new SidenavRenderer(), new FalseRenderGuard(), expectations, 4);
    }

    ////////////////////////////////////////////////////////////////
    // Test methods
    ////////////////////////////////////////////////////////////////

    private void rendererTest(Renderable r, RenderGuard guard, Map exp, int depth) {
        rendererTest(r, forgeNavNode(), guard, exp, depth);
    }

    private void rendererTest(Renderable r, NavNode node, RenderGuard guard,
            Map exp, int depth) {

        NavTreeIndex treeIndex = forgeTreeIndex();
        rendererTest(r, node, guard, treeIndex, exp, depth);
    }

    private void rendererTest(Renderable r, NavNode node, RenderGuard guard,
                              NavTreeIndex treeIndex, Map exp, int depth) {

        r.setRenderGuard(guard);


        // preNavLevel
        StringBuffer buf = new StringBuffer();
        r.preNavLevel(buf, depth);
        assertEquals(exp.get("preNavLevel"), buf.toString());

        // preNavNode
        buf = new StringBuffer();
        r.preNavNode(buf, depth);
        assertEquals(exp.get("preNavNode"), buf.toString());


        // navNodeActive
        buf = new StringBuffer();
        r.navNodeActive(buf, node, treeIndex, null, depth);
        assertEquals(exp.get("navNodeActive"), buf.toString());

        // navNodeInactive
        buf = new StringBuffer();
        r.navNodeInactive(buf, node, treeIndex, null, depth);
        assertEquals(exp.get("navNodeInactive"), buf.toString());

        // postNavNode
        buf = new StringBuffer();
        r.postNavNode(buf, depth);
        assertEquals(exp.get("postNavNode"), buf.toString());

        // postNavLevel
        buf = new StringBuffer();
        r.postNavLevel(buf, depth);
        assertEquals(exp.get("postNavLevel"), buf.toString());

        // nodeRenderInline
        boolean rc = r.nodeRenderInline(depth);
        Boolean v = (Boolean) exp.get("nodeRenderInline");
        assertEquals(v.booleanValue(), rc);

        // cleanup
        buf = null;
    }

    private NavTreeIndex forgeTreeIndex() {
        return new NavTreeIndex(new NavTree());
    }

    private NavNode forgeNavNode() {
        NavNode node = new NavNode();

        node.addURL("http://rhn.redhat.com");
        node.setLabel("label");
        node.setName("name");
        node.setAcl("acl");
        node.setDominant(true);
        node.setInvisible(false);
        node.setOverrideSidenav(false);
        node.setShowChildrenIfActive(true);
        node.setPermFailRedirect("permFailRedirect");
        node.setActiveImage("activeImage");
        node.setInactiveImage("inactiveImage");
        node.setOnClick("onClick");
        node.setDynamicChildren("dynamicChildrenIn");

        return node;
    }

    ////////////////////////////////////////////////////////////////
    // INNER CLASSES
    ////////////////////////////////////////////////////////////////

    /**
     * A render guard that returns false for canRender for negative
     * testing.
     */
    public static class FalseRenderGuard implements RenderGuard {

        /**
         * method called to decide if to render
         * @param node the current NavNode
         * @param depth the current depth
         * @return boolean whether or not to render
         */
        public boolean canRender(NavNode node, int depth) {
            return false;
        }
    }

    /**
     * A render guard that returns false for canRender for negative
     * testing.
     */
    public static class TrueRenderGuard implements RenderGuard {

        /**
         * method called to decide if to render
         * @param node the current NavNode
         * @param depth the current depth
         * @return boolean whether or not to render
         */
        public boolean canRender(NavNode node, int depth) {
            return true;
        }
    }
}
