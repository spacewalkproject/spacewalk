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
package com.redhat.rhn.frontend.action.systems.virtualization.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.virtualization.VirtualizationSetMemoryAction;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.server.VirtualInstanceFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.taglibs.ListDisplayTag;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;

import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;


/**
 * VirtualGuestsListActionTest
 * @version $Rev$
 */
public class VirtualGuestsActionTest extends RhnMockStrutsTestCase {

    private RhnSet submitVirtualGuestsForm(String dispatch, Map requestParams)
        throws Exception {
        Server guest = ServerFactoryTest.createTestServer(
                user,
                true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled(),
                ServerFactoryTest.TYPE_SERVER_NORMAL
        );

        Server host = ServerFactoryTest.createTestServer(
                user,
                true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled(),
                ServerFactoryTest.TYPE_SERVER_NORMAL
        );

        VirtualInstance virtualInstance = new VirtualInstance();
        virtualInstance.setUuid("1234");
        virtualInstance.setGuestSystem(guest);
        virtualInstance.setHostSystem(host);
        virtualInstance.setState(VirtualInstanceFactory.getInstance().getRunningState());

        addRequestParameter(RequestContext.SID, host.getId().toString());

        for (Iterator iter = requestParams.keySet().iterator(); iter.hasNext();) {
            String key = (String)iter.next();
            String value = (String)requestParams.get(key);
            addRequestParameter(key, value);
        }

        addDispatchCall(dispatch);
        RhnSet set = RhnSetDecl.VIRTUAL_SYSTEMS.get(user);
        set.addElement(virtualInstance.getId());
        RhnSetManager.store(set);

        set = RhnSetDecl.VIRTUAL_SYSTEMS.get(user);
        setRequestPathInfo("/systems/details/virtualization/VirtualGuestsListSubmit");
        actionPerform();
        return set;
    }

    public void testDeleteGuest() throws Exception {
        Map requestParams = new HashMap();
        requestParams.put("guestAction", "Delete Systems");
        RhnSet set = submitVirtualGuestsForm("virtualguestslist.jsp.applyaction",
                requestParams);

        verifyNoActionMessages();
        assertTrue(getActualForward().endsWith("actionName=delete"));
        assertTrue(getActualForward().indexOf("guestSettingValue") <= 0);

        // Test some of the base list buttons
        addDispatchCall(ListDisplayTag.UNSELECT_ALL_KEY);
        assertEquals(1, set.size());
        actionPerform();
        set = RhnSetDecl.VIRTUAL_SYSTEMS.get(user);
        assertEquals(0, set.size());
        assertTrue(getActualForward().indexOf("sid=") > 0);
    }

    public void testDeleteGuestConfirm() throws Exception {
        Server host = ServerTestUtils.createVirtHostWithGuests(user, 1);
        Server guest =
            ((VirtualInstance) host.getGuests().iterator().next()).getGuestSystem();

        VirtualInstance virtualInstance = new VirtualInstance();
        virtualInstance.setUuid("1234");
        virtualInstance.setGuestSystem(guest);

        ServerFactory.save(guest);
        new VirtualInstanceFactory().saveVirtualInstance(virtualInstance);

        addRequestParameter(RequestContext.SID, host.getId().toString());
        addDispatchCall("virtualguests_confirm.jsp.confirm");
        RhnSet set = RhnSetDecl.VIRTUAL_SYSTEMS.get(user);
        set.addElement(virtualInstance.getId());
        RhnSetManager.store(set);
        TestUtils.flushAndEvict(virtualInstance);
        TestUtils.flushAndEvict(host);
        TestUtils.flushAndEvict(guest);

        addRequestParameter("actionName", "delete");
        setRequestPathInfo("/systems/details/virtualization/VirtualGuestsConfirmSubmit");
        actionPerform();
        TestUtils.flushAndEvict(virtualInstance);
        assertNull(ServerFactory.lookupById(guest.getId()));
        assertNotNull(ServerFactory.lookupById(host.getId()));
        verifyActionMessage("systems.details.virt.one.virt.deleted");
        Map params = new HashMap();
        params.put("id", virtualInstance.getId());
        DataResult dr = TestUtils.runTestQuery("select_virtual_instance_by_id", params);
        assertTrue(dr.size() == 0);
    }

    public void testSetGuestMemory() throws Exception {
        Map requestParams = new HashMap();
        requestParams.put("guestSettingToModify", "Memory");
        requestParams.put("guestSettingValue", "1000");
        submitVirtualGuestsForm("virtualguestslist.jsp.applychanges",
                requestParams);

        verifyActionMessage("systems.details.virt.memory.check.host");
        assertTrue(getActualForward().indexOf("actionName=setMemory") >= 0);
        assertTrue(getActualForward().indexOf("guestSettingValue") >= 0);
    }

    public void testSetGuestMemoryConfirm() throws Exception {
        Server host = ServerTestUtils.createVirtHostWithGuests(user, 1);
        addRequestParameter(RequestContext.SID, host.getId().toString());
        addDispatchCall("virtualguests_confirm.jsp.confirm");
        RhnSet set = RhnSetDecl.VIRTUAL_SYSTEMS.get(user);
        VirtualInstance vi = ((VirtualInstance) host.getGuests().iterator().next());
        vi.setState(VirtualInstanceFactory.getInstance().getRunningState());
        TestUtils.saveAndFlush(vi);
        set.addElement(vi.getId());
        RhnSetManager.store(set);

        addRequestParameter("actionName", "setMemory");
        addRequestParameter("guestSettingValue", "1000");
        setRequestPathInfo("/systems/details/virtualization/VirtualGuestsConfirmSubmit");
        actionPerform();
        List <Action> actions = ActionFactory.listActionsForServer(user, host);
        Collections.reverse(actions);
        assertNotNull(actions);
        VirtualizationSetMemoryAction vaction = null;
        for (Action action : actions) {
            if (action instanceof  VirtualizationSetMemoryAction) {
                vaction = (VirtualizationSetMemoryAction) action;
                break;
            }
        }
        assertNotNull(vaction);
        assertEquals(Integer.valueOf(1024000), vaction.getMemory());
    }

    public void testSetGuestVcpus() throws Exception {
        Map requestParams = new HashMap();
        requestParams.put("guestSettingToModify", "Virtual CPU");
        requestParams.put("guestSettingValue", "3");
        submitVirtualGuestsForm("virtualguestslist.jsp.applychanges",
                requestParams);

        verifyNoActionMessages();
        assertTrue(getActualForward().indexOf("actionName=setVcpu") >= 0);
        assertTrue(getActualForward().indexOf("guestSettingValue") >= 0);
    }

}
