/**
 * Copyright (c) 2014 SUSE LLC
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
package com.redhat.rhn.frontend.events.test;

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.events.CloneErrataAction;
import com.redhat.rhn.frontend.events.CloneErrataEvent;
import com.redhat.rhn.manager.channel.CloneChannelCommand;
import com.redhat.rhn.taskomatic.task.TaskConstants;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;

/**
 * Tests {@link CloneErrataAction}.
 */
public class CloneErrataActionTest extends BaseTestCaseWithUser {

    private User admin;

    /**
     * {@inheritDoc}
     */
    @Override
    public void setUp() throws Exception {
        super.setUp();
        admin = UserTestUtils.createUserInOrgOne();
        admin.getOrg().addRole(RoleFactory.ORG_ADMIN);
        TestUtils.saveAndFlush(admin);
    }

    /**
     * Tests doExecute().
     * @throws Exception if something bad happens
     */
    public void testDoExecute() throws Exception {
        // setup a channel with an errata
        Channel original = ChannelFactoryTest.createTestChannel(admin);
        final Errata errata =
                ErrataFactoryTest.createTestPublishedErrata(admin.getOrg().getId());
        original.addErrata(errata);

        // clone it
        CloneChannelCommand helper = new CloneChannelCommand(true, original);
        helper.setName("Test Clone of " + original.getName());
        helper.setArchLabel(original.getChannelArch().getLabel());
        helper.setLabel("test-clone-of-" + original.getLabel());
        helper.setUser(admin);
        helper.setSummary(original.getSummary());
        helper.setChecksumLabel("sha256");
        Channel cloned = helper.create();

        // check cloned channel has no errata and repository metadata
        // generation was scheduled
        assertEquals(0, cloned.getErrataCount());
        assertEquals(1, countActiveRepomdTasks(cloned.getLabel()));

        // run CloneErrataAction
        Collection<Long> errataIds = new LinkedList<Long>() { { add(errata.getId()); } };
        CloneErrataEvent event = new CloneErrataEvent(cloned, errataIds, user);
        new CloneErrataAction().doExecute(event);

        // new errata should be in cloned channel, new repository metadata
        // generation scheduled
        assertEquals(1, cloned.getErrataCount());
        assertEquals(2, countActiveRepomdTasks(cloned.getLabel()));
    }

    /**
     * Count the active repomd tasks for a given channel.
     * @param label the channel label to process
     * @return the count of repomd tasks
     */
    private int countActiveRepomdTasks(String label) {
        SelectMode selector = ModeFactory.getMode(TaskConstants.MODE_NAME,
            TaskConstants.TASK_QUERY_REPOMD_CANDIDATES_DETAILS_QUERY);
        Map<Object, Object> params = new HashMap<Object, Object>();
        params.put("channel_label", label);
        return selector.execute(params).size();
    }
}
