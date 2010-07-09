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
package com.redhat.rhn.frontend.action.systems.monitoring.test;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.command.Command;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;
import com.redhat.rhn.domain.monitoring.test.MonitoringTestUtils;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.monitoring.BaseProbeAction;
import com.redhat.rhn.frontend.action.systems.monitoring.BaseProbeCreateAction;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.monitoring.ModifyProbeCommand;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.ForwardWrapper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpSession;

import org.apache.commons.lang.StringUtils;
import org.hibernate.HibernateException;

import java.util.HashMap;
import java.util.List;
import java.util.Set;

public abstract class ProbeCreateTestCase extends RhnBaseTestCase {

    protected static final String BASE_REQ_ATTRS =
        "intervals,contactGroups,commandGroups,command,commands,satClusters," +
        "paramValueList";
    protected User user;
    protected ActionHelper ah;

    /**
     * {@inheritDoc}
     */
    protected void setUp() throws Exception {
        super.setUp();
        ah = new ActionHelper();
        ah.setUpAction(createProbeAction());
        ah.getForm().setFormName("probeCreateForm");
        user = ah.getUser();
    }

    /**
     * {@inheritDoc}
     */
    protected void tearDown() throws Exception {
        user = null;
        super.tearDown();
    }

    public final void testMissingParams() throws Exception {
        modifyActionHelper("default");

        Probe orig = MonitoringFactoryTest.createTestProbe(user);

        ah.getForm().set(RhnAction.SUBMITTED, Boolean.TRUE);
        setupCommand(ah, orig);
        setupProbeFields(ah, orig);

        HashMap params = MonitoringTestUtils.makeParamDefaults(orig.getCommand(), true);
        // Remove required param
        params.put("r_port_0", "");
        MonitoringTestUtils.setupParamValues(ah, params, 3);

        ForwardWrapper af = ah.executeAction();
        assertEquals("default", af.getName());
    }

    public final void testExecute() throws Exception {

        modifyActionHelper("default");
        setupCommand(ah, null);
        ForwardWrapper af = ah.executeAction();

        assertEquals("default", af.getName());
        Command command = (Command) ah.getRequest().getAttribute("command");
        assertNotNull(command);
        assertEquals(command.getName(), ModifyProbeCommand.COMMAND_DEFAULT);
        // bugzilla 137078
        String expectedDesc = command.getCommandGroup().getDescription() +
                LocalizationService.getInstance().
                    getMessage("punctuation.colonwithspace") +
                        command.getDescription();
        String gotDesc = (String) ah.getForm().get("description");
        assertEquals(expectedDesc, gotDesc);

        assertHasRequestAttributes(ah, requestAttributes());
        List pvalues = (List) ah.getRequest().getAttribute("paramValueList");
        assertTrue(pvalues.size() > 0);
        // bugzilla 159421
        assertEquals(ModifyProbeCommand.CHECK_INTERVAL_DEFAULT,
                    ah.getForm().get("check_interval_min"));
        assertEquals(ModifyProbeCommand.NOTIF_INTERVAL_DEFAULT,
                ah.getForm().get("notification_interval_min"));

    }

    public final void testSelectedCommand() throws Exception {
        modifyActionHelper("default");
        RhnMockHttpSession session = (RhnMockHttpSession) ah.getRequest().getSession();
        session.setAttribute(
                BaseProbeCreateAction.SELECTED_COMMAND_GROUP_SESSION, "tools");
        session.setAttribute(
                BaseProbeCreateAction.SELECTED_COMMAND_SESSION, "check_nothing");

        setupCommand(ah, null);
        ForwardWrapper af = ah.executeAction();

        assertEquals("default", af.getName());
        Command command = (Command) ah.getRequest().getAttribute("command");
        assertNotNull(command);
        assertEquals("tools", command.getCommandGroup().getGroupName());
        assertEquals("check_nothing", command.getName());
    }

    public final void testThresholdParamsAscending() throws Exception {
        // bugzilla 161387

        Probe orig = MonitoringFactoryTest.createTestProbe(user);

        modifyActionHelper("default");
        ah.getForm().set(RhnAction.SUBMITTED, Boolean.TRUE);
        setupCommand(ah, orig);
        setupProbeFields(ah, orig);

        HashMap params = MonitoringTestUtils.makeParamDefaults(orig.getCommand(), true);
        // Make sure that the values are not in ascending order
        params.put("warning", "7");
        params.put("critical", "7");
        MonitoringTestUtils.setupParamValues(ah, params, 3);

        ForwardWrapper af = ah.executeAction();
        assertEquals("default", af.getName());
    }

    protected abstract BaseProbeAction createProbeAction();

    protected abstract String requestAttributes();

    protected abstract void modifyActionHelper(String forwardName) throws Exception;

    protected void assertHasRequestAttributes(ActionHelper actionHelper,
            String reqAttrStr) {
        String[] reqAttrs = StringUtils.split(reqAttrStr, ",");
        assertTrue(reqAttrs.length > 0);
        RhnMockHttpServletRequest req = actionHelper.getRequest();
        for (int i = 0; i < reqAttrs.length; i++) {
            assertNotNull(reqAttrs[i], req.getAttribute(reqAttrs[i]));
        }
    }

    protected void assertNoRequestAttributes(ActionHelper actionHelper,
            String reqAttrStr) {
        String[] reqAttrs = StringUtils.split(reqAttrStr, ",");
        assertTrue(reqAttrs.length > 0);
        for (int i = 0; i < reqAttrs.length; i++) {
            assertNull(reqAttrs[i], actionHelper.getRequest().getAttribute(reqAttrs[i]));
        }
    }

    protected void setupCommand(ActionHelper actionHelper, Probe orig) {
        String groupName = "";
        String commandName = "";
        if (orig != null) {
            groupName = orig.getCommand().getCommandGroup().getGroupName();
            commandName = orig.getCommand().getName();
        }
        actionHelper.getForm().set("command_group", groupName);
        actionHelper.getForm().set("command", commandName);
    }

    protected void setupProbeFields(ActionHelper actionHelper, Probe probe) {
        Long scoutID = firstScoutID();
        actionHelper.getForm().set("sat_cluster_id", scoutID);
        actionHelper.getForm().set("description", probe.getDescription());
        actionHelper.getForm().set("old_description", probe.getDescription());
        actionHelper.getForm().set("notification", Boolean.TRUE);
        actionHelper.getForm().set("check_interval_min", probe.getCheckIntervalMinutes());
        actionHelper.getForm().set("notification_interval_min",
                probe.getNotificationIntervalMinutes());
    }

    protected Long firstScoutID() {
        Set scouts = user.getOrg().getMonitoringScouts();
        Long scoutID = ((SatCluster) scouts.iterator().next()).getId();
        assertTrue(scouts.size() > 0);
        return scoutID;
    }

    protected Probe verifyProbe(Probe orig, Class probeClass, Long newID)
        throws HibernateException {
        Probe created = (Probe) reload(probeClass, newID);
        assertNotNull(created);
        assertTrue(!created.getId().equals(orig.getId()));
        assertEquals(orig.getDescription(), created.getDescription());
        assertEquals(orig.getCommand().getName(), created.getCommand()
                .getName());
        assertEquals(orig.getCheckIntervalMinutes(), created
                .getCheckIntervalMinutes());
        return created;
    }


}
