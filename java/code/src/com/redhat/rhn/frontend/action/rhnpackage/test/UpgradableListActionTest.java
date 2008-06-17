/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.rhnpackage.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.action.rhnpackage.UpgradableListAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.action.ActionForward;

/**
 * UpgradableListActionTest
 * @version $Rev$
 */
public class UpgradableListActionTest extends RhnBaseTestCase {
    
    public void testUpgradeDownload() throws Exception {
        UpgradableListAction action = new UpgradableListAction();
        ActionHelper ah = new ActionHelper();
        
        ah.setUpAction(action, "upgrade");
        Server server = ServerFactoryTest.createTestServer(ah.getUser());
        
        ah.getRequest().setupAddParameter("sid", server.getId().toString());
        ah.getRequest().setupAddParameter("newset", (String)null);
        ah.getRequest().setupAddParameter("items_on_page", (String)null);
        ah.getRequest().setupAddParameter("items_selected", "2346");
        ActionForward af = ah.executeAction("upgrade");
        assertEquals("upgrade", af.getName());
        
        ah.setUpAction(action, "download");
        ah.getRequest().setupAddParameter("sid", server.getId().toString());
        ah.getRequest().setupAddParameter("newset", (String)null);
        ah.getRequest().setupAddParameter("items_on_page", (String)null);
        ah.getRequest().setupAddParameter("items_selected", "2346");
        af = ah.executeAction("download");
        assertEquals("download", af.getName());
    }
    
    public void testDefaultForward() throws Exception {
        UpgradableListAction action = new UpgradableListAction();
        ActionHelper ah = new ActionHelper();
        
        ah.setUpAction(action, "default");
        ah.setupProcessPagination();
        Server server = ServerFactoryTest.createTestServer(ah.getUser());
        
        ah.getRequest().setupAddParameter("sid", server.getId().toString());
        ah.getRequest().setupAddParameter("newset", (String[])null);
        ah.getRequest().setupAddParameter("items_on_page", (String[])null);
        ah.getRequest().setupAddParameter("items_selected", (String[])null);
        ActionForward af = ah.executeAction("download");
        assertEquals("default", af.getName());
        
        ah.setupProcessPagination();
        ah.getRequest().setupAddParameter("sid", server.getId().toString());
        ah.getRequest().setupAddParameter("newset", (String[])null);
        ah.getRequest().setupAddParameter("items_on_page", (String[])null);
        ah.getRequest().setupAddParameter("items_selected", (String[])null);
        af = ah.executeAction("upgrade");
        assertEquals("default", af.getName());
    }
    
    public void testTooManyDownload() throws Exception {
        UpgradableListAction action = new UpgradableListAction();
        ActionHelper ah = new ActionHelper();
        
        ah.setUpAction(action, "default");
        ah.setupProcessPagination();
        Server server = ServerFactoryTest.createTestServer(ah.getUser());
        
        Config c = Config.get();
        String orig = c.getString("download_tarball_max");
        c.setString("download_tarball_max", "2");
        String[] ids = new String[3];
        ids[0] = "23456"; 
        ids[0] = "23542";
        ids[0] = "63523";
        
        ah.getRequest().setupAddParameter("sid", server.getId().toString());
        ah.getRequest().setupAddParameter("newset", (String[])null);
        ah.getRequest().setupAddParameter("items_on_page", (String[])null);
        ah.getRequest().setupAddParameter("items_selected", (String[])null);
        ActionForward af = ah.executeAction("download");
        assertEquals("default", af.getName());
        c.setString("download_tarball_max", orig);
    }

}
