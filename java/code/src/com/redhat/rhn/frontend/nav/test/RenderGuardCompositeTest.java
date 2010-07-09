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

import com.redhat.rhn.frontend.nav.NavNode;
import com.redhat.rhn.frontend.nav.RenderGuard;
import com.redhat.rhn.frontend.nav.RenderGuardComposite;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * RenderGuardCompositeTest
 * @version $Rev$
 */
public class RenderGuardCompositeTest extends RhnBaseTestCase {

    public void testNoGuards() {
        RenderGuardComposite comp = new RenderGuardComposite();
        boolean rc = comp.canRender(null, 0);
        assertTrue(rc);
    }

    public void testNullGuards() {
        RenderGuardComposite comp = new RenderGuardComposite();
        comp.addRenderGuard(null);
        boolean rc = comp.canRender(null, 0);
        assertTrue(rc);
    }

    // 0 = false
    public void testRenderGuard0() {
        RenderGuardComposite comp = new RenderGuardComposite();
        comp.addRenderGuard(new FalseGuard());
        boolean rc = comp.canRender(null, 0);
        assertFalse(rc);
    }

    // 1 = true
    public void testRenderGuard1() {
        RenderGuardComposite comp = new RenderGuardComposite();
        comp.addRenderGuard(new TrueGuard());
        boolean rc = comp.canRender(null, 0);
        assertTrue(rc);
    }

    // 2 -> 10 -> true & false -> false
    public void testRenderGuard2() {
        RenderGuardComposite comp = new RenderGuardComposite();
        comp.addRenderGuard(new TrueGuard());
        comp.addRenderGuard(new FalseGuard());
        boolean rc = comp.canRender(null, 0);
        assertFalse(rc);
    }

    // 3 -> 11 -> true & true -> true
    public void testRenderGuard3() {
        RenderGuardComposite comp = new RenderGuardComposite();
        comp.addRenderGuard(new TrueGuard());
        comp.addRenderGuard(new TrueGuard());
        boolean rc = comp.canRender(null, 0);
        assertTrue(rc);
    }

    // 7 -> 111 -> true & true & true -> true
    public void testRenderGuard7() {
        RenderGuardComposite comp = new RenderGuardComposite();
        comp.addRenderGuard(new TrueGuard());
        comp.addRenderGuard(new TrueGuard());
        comp.addRenderGuard(new TrueGuard());
        boolean rc = comp.canRender(null, 0);
        assertTrue(rc);
    }

    public static class TrueGuard implements RenderGuard {

        public boolean canRender(NavNode node, int depth) {
            return true;
        }
    }

    public static class FalseGuard implements RenderGuard {

        public boolean canRender(NavNode node, int depth) {
            return false;
        }
    }
}
