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
package com.redhat.rhn.frontend.xmlrpc.kickstart.snippet.test;

import com.redhat.rhn.domain.kickstart.cobbler.CobblerSnippet;
import com.redhat.rhn.frontend.xmlrpc.kickstart.snippet.SnippetHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;

import java.util.List;

/**
 * SnippetHandlerTest
 * @version $Rev$
 */
public class SnippetHandlerTest extends BaseHandlerTestCase {
    
    private SnippetHandler handler = new SnippetHandler();

    public void testListAll() {
        deleteAllSnippets();
        assertTrue(handler.listAll(adminKey).isEmpty());
        CobblerSnippet.createOrUpdate(true, "foo", "My foo snippet", admin.getOrg());
        assertFalse(handler.listAll(adminKey).isEmpty());
    }
    
    public void testListCustom() {
        deleteAllSnippets();
        assertTrue(handler.listCustom(adminKey).isEmpty());
        CobblerSnippet.createOrUpdate(true, "foo", "My foo snippet", admin.getOrg());
        assertFalse(handler.listCustom(adminKey).isEmpty());
    }
    
    
    public void testCreateOrUpdate() {
        deleteAllSnippets();
        handler.createOrUpdate(adminKey, "foobar", "My Little foobar");
        assertTrue(handler.listAll(adminKey).get(0).getName().equals("foobar"));
    }
    
    public void testDelete() {
        deleteAllSnippets();
        handler.createOrUpdate(adminKey, "foobar", "My Little foobar");
        assertTrue(handler.listAll(adminKey).get(0).getName().equals("foobar"));
        handler.delete(adminKey, "foobar");
        assertTrue(handler.listCustom(adminKey).isEmpty());
    }
    
    
    private void deleteAllSnippets() {
        List<CobblerSnippet> list = handler.listCustom(adminKey);
        for (CobblerSnippet snip : list) {
            snip.delete();
        }
    }
    
    
    
    
    
}
