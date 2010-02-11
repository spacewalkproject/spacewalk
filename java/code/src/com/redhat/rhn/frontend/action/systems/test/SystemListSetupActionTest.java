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
package com.redhat.rhn.frontend.action.systems.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.action.systems.SystemListSetupAction;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

import java.util.Date;
import java.util.Iterator;

/**
 * SystemListSetupActionTest
 * @version $Rev$
 */
public class SystemListSetupActionTest extends RhnMockStrutsTestCase {
    public void setUp() throws Exception {
        super.setUp();
        setRequestPathInfo("/systems/SystemList");
    }
    
    public void testPerformExecute() throws Exception {
        ServerFactoryTest.createTestServer(user, true);
        actionPerform();
        DataResult dr = (DataResult) request.getAttribute("pageList");
        assertTrue(dr.size() > 0);
    }
    
    public void aTestSetStatusDisplay() throws Exception {
        
        SystemListSetupAction action = new SystemListSetupAction();
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerFactoryTest.createTestServer(user, true,
                ServerFactory.lookupServerGroupTypeByLabel("sw_mgr_entitled"));
        Long sid = server.getId();
        
        PageControl pc = new PageControl();
        pc.setPageSize(50);
        pc.setStart(1);
        boolean isThere = false;
        DataResult dr = SystemManager.systemList(user, pc);
        
        LocalizationService ls = LocalizationService.getInstance();
        // TODO: This looks a bit on the fragile side:
        String up2date = "<a><img src=\"/img/icon_up2date.gif\" title=\"" +
                         ls.getMessage("systemlist.jsp.up2date") + "\" alt=\"" +
                         ls.getMessage("systemlist.jsp.up2date") + "\" /></a>";
        String awol = "<a href=\"/rhn/help/reference/en-US/s1-sm-systems.jsp" +
                      "\"><img src=\"/img/icon_checkin.gif\" " +
                      "alt=\"" + ls.getMessage("systemlist.jsp.notcheckingin") + "\" " +
                      "title=\"" + ls.getMessage("systemlist.jsp.notcheckingin") +
                      "\" /></a>";


        //Page through all the systems because we don't know where our new system is
        //We can't elaborate the entire list because there is a 1000 list member limit
        while (!isThere && pc.getStart() <= dr.getTotalSize()) {
            action.setStatusDisplay(dr, user);
            isThere = findStatus(dr, up2date, sid);
            pc.setStart(pc.getStart() + 50);
            dr = SystemManager.systemList(user, pc);
        }
        assertTrue(isThere);

        int secondsOld = Config.get().getInt(ConfigDefaults.SYSTEM_CHECKIN_THRESHOLD) *
                         86400000 + 50000000;
        //awol
        Date now = new Date();
        // A date a little older than the checkin threshold
        Date ago = new Date(now.getTime() - secondsOld);
        server.getServerInfo().setCheckin(ago);
        ServerFactory.save(server);
        
        pc.setStart(1);
        isThere = false;
        dr = SystemManager.systemList(user, pc);
        
        //Page through all the systems because we don't know where our new system is
        while (!isThere && pc.getStart() <= dr.getTotalSize()) {
            action.setStatusDisplay(dr, user);
            isThere = findStatus(dr, awol, sid);
            pc.setStart(pc.getStart() + 50);
            dr = SystemManager.systemList(user, pc);
        }
        assertTrue(isThere);
        
    }
    
    private boolean findStatus(DataResult dr, String status, Long sid) {
        boolean isThere = false;
        Iterator i = dr.iterator();
        while (i.hasNext() && !isThere) {
            SystemOverview next = (SystemOverview)i.next();
            if ((next.getId().longValue() == sid.longValue())) {
                isThere = true;
            }
        }
        return isThere;
        
    }

}
