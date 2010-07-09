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
package com.redhat.rhn.manager.kickstart.cobbler.test;

import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.kickstart.cobbler.CobblerSnippet;
import com.redhat.rhn.domain.kickstart.cobbler.test.CobblerSnippetTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerSnippetLister;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import java.util.List;


/**
 * CobblerSnippetListerTest
 * @version $Rev$
 */
public class CobblerSnippetListerTest extends BaseTestCaseWithUser {
    public void testPerms() throws Exception {
        try {
            CobblerSnippetLister.getInstance().list(user);
            fail("Yuck permission failures not caught");
        }
        catch (PermissionException pe) {
            //cool permission breakups
        }
    }

    public void testList() throws Exception {
        user.addRole(RoleFactory.CONFIG_ADMIN);
        CobblerSnippet snip = CobblerSnippetTest.readOnly();
        List <CobblerSnippet> snips =
            CobblerSnippetLister.getInstance().list(user);
        assertTrue(snips.contains(snip));
        snips =
            CobblerSnippetLister.getInstance().listDefault(user);
        assertTrue(snips.contains(snip));

        CobblerSnippet snip2 = CobblerSnippetTest.editable(user);
        snips =
            CobblerSnippetLister.getInstance().list(user);
        assertTrue(snips.contains(snip2));
        snips =
            CobblerSnippetLister.getInstance().listCustom(user);
        assertTrue(snips.contains(snip2));
        snips =
            CobblerSnippetLister.getInstance().listDefault(user);
        assertFalse(snips.contains(snip2));
        snip2.delete();
        snips =
            CobblerSnippetLister.getInstance().list(user);
        assertFalse(snips.contains(snip2));

        snips =
            CobblerSnippetLister.getInstance().listCustom(user);
        assertFalse(snips.contains(snip2));
    }
}
