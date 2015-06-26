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

import com.redhat.rhn.frontend.nav.DepthGuard;
import com.redhat.rhn.frontend.nav.NavCache;
import com.redhat.rhn.frontend.nav.NavDigester;
import com.redhat.rhn.frontend.nav.NavNode;
import com.redhat.rhn.frontend.nav.NavTree;
import com.redhat.rhn.frontend.nav.NavTreeIndex;
import com.redhat.rhn.frontend.nav.RenderEngine;
import com.redhat.rhn.frontend.nav.Renderable;
import com.redhat.rhn.frontend.nav.SidenavRenderer;
import com.redhat.rhn.frontend.nav.TextRenderer;
import com.redhat.rhn.frontend.nav.TopnavRenderer;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.time.StopWatch;
import org.apache.log4j.Logger;

public class NavTest extends RhnBaseTestCase {
    private static Logger log = Logger.getLogger(NavTest.class);

    /**
     * {@inheritDoc}
     */
    protected void setUp() throws Exception {
        super.setUp();
        TestUtils.disableLocalizationLogging();
    }

    public void testCache() throws Exception {
        NavTree realTree = NavDigester.buildTree(TestUtils.findTestData("sitenav.xml"));
        NavTree cacheTree1 = NavCache.getTree(TestUtils.findTestData("sitenav.xml"));
        NavTree cacheTree2 = NavCache.getTree(TestUtils.findTestData("sitenav.xml"));

        assertNotSame(realTree, cacheTree1);
        assertSame(cacheTree1, cacheTree2);
    }

    public void testDigester() throws Exception {
        StopWatch st = new StopWatch();
        st.start();
        NavTree nt =
            NavDigester.buildTree(TestUtils.findTestData("sitenav.xml"));
        assertTrue(nt.getTitleDepth() == 0);
        assertTrue(nt.getLabel().equals("sitenav_unauth"));
        assertNotNull(nt.getAclMixins());

        NavTreeIndex nti = new NavTreeIndex(nt);

        String testPath = "/rhn/help/index.do";
        nti.computeActiveNodes(testPath, null);

        NavNode bestNode = nti.getBestNode();
        assertEquals(bestNode.getName(), "Help Desk");
        assertEquals(bestNode.getPrimaryURL(), testPath);

        log.info("Index Duration: " +
                       st.getTime() / 1000f + " seconds");

        RenderEngine nr = new RenderEngine(nti);
        st.stop();

        Renderable[] renderers = new Renderable[3];

        renderers[0] = new SidenavRenderer();

        renderers[1] = new TopnavRenderer();
        renderers[1].setRenderGuard(new DepthGuard(0, 0));

        renderers[2] = new TextRenderer();
        renderers[2].setRenderGuard(new DepthGuard(1, Integer.MAX_VALUE));

        for (int i = 0; i < renderers.length; i++) {
            log.info("Using Renderable " +
                           renderers[i].getClass() + ":\n" +
                           nr.render(renderers[i]));
        }

        log.info("Parse Duration: " +
                       st.getTime() / 1000f + " seconds");

    }

    public void testUrlSplit() throws Exception {
        String[] testUrls = new String[] {
            "/",
            "/foo",
            "/foo/",
            "/foo/bar",
            "/foo/bar/",
            "/foo/bar/baz/"
        };

        String[] expected = new String[] {
            "/",
            "/foo:/",
            "/foo:/",
            "/foo/bar:/foo:/",
            "/foo/bar:/foo:/",
            "/foo/bar/baz:/foo/bar:/foo:/"
        };

        for (int i = 0; i < testUrls.length; i++) {
            String[] prefixes = NavTreeIndex.splitUrlPrefixes(testUrls[i]);
            String result = StringUtils.join(prefixes, ":");

            assertEquals(result, expected[i]);
        }
    }

    public void testLastMappedPath() throws Exception {

        NavTree nt =
            NavDigester.buildTree(TestUtils.findTestData("sitenav.xml"));

        NavTreeIndex nti = new NavTreeIndex(nt);

        String testPath = "/SOMEUNKNOWNURLTHATHASNOMAPPING.html";
        String lastPath = "/rhn/systems/SystemEntitlements.do";
        // Here we want to make sure our "Best Node" is what is used in the last
        // path.
        String activePath = nti.computeActiveNodes(testPath, lastPath);

        NavNode bestNode = nti.getBestNode();
        assertEquals(bestNode.getName(), "Subscription Management");
        assertEquals(bestNode.getPrimaryURL(), lastPath);
        assertEquals(bestNode.getPrimaryURL(), activePath);
    }

    public void testMatchByUrl() throws Exception {
        NavTree nt =
            NavDigester.buildTree(TestUtils.findTestData("sitenav.xml"));

        NavTreeIndex nti = new NavTreeIndex(nt);
        String lastPath = "/rhn/help/dispatcher/release_notes";
        String curPath = "/rhn/help/dispatcher/reference_guide";
        nti.computeActiveNodes(curPath, lastPath);
        NavNode bestNode = nti.getBestNode();
        assertEquals("/rhn/help/about.do", bestNode.getPrimaryURL());
    }

    public void testMatchByDir() throws Exception {
        NavTree nt =
            NavDigester.buildTree(TestUtils.findTestData("sitenav.xml"));

        NavTreeIndex nti = new NavTreeIndex(nt);
        nti.computeActiveNodes("/rhn/help/satellite", "");
        NavNode bestNode = nti.getBestNode();
        assertEquals("/rhn/help/dispatcher/install_guide", bestNode.getPrimaryURL());
    }
}


