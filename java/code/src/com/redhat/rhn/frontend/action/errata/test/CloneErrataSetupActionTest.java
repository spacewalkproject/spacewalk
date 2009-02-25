/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.errata.test;

import java.util.List;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.action.errata.CloneErrataActionHelper;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;

/**
 * CloneErrataSetupActionTest
 * @version $Rev$
 */
public class CloneErrataSetupActionTest extends RhnMockStrutsTestCase {
    
    public void setUp() throws Exception {
        super.setUp();
        setRequestPathInfo("/errata/manage/CloneErrata");
        user.getOrg().getEntitlements().add(OrgFactory.getEntitlementEnterprise());
        user.getOrg().addRole(RoleFactory.CHANNEL_ADMIN);
    }
    
    /**
     * We have no guarantee that there aren't already cloned channels in
     * the test database. Therefore, we need to find out how many are
     * in the cloned channel dropdown list BEFORE we insert our test channel
     * into the database, then verify that we get the number of cloned
     * channels we originally got back plus one (the extra one being our
     * new channel).
     * @throws Exception
     */
    public void testDropDownList() throws Exception {
        
        actionPerform();
        List channelList = (List) request.getAttribute("clonablechannels");
        int oldSize = channelList.size();
        ChannelFactoryTest.createTestClonedChannel(
                                     ChannelFactoryTest.createTestChannel(user), 
                                     user);
        
        actionPerform();
        channelList = (List) request.getAttribute("clonablechannels");
        assertNotNull(channelList);
        assertTrue(channelList.size() == oldSize + 1);
    }
    
    /**
     * Same rules apply here as the above test. We're not guaranteed any particular
     * number of results in our pageList, but we know it should be n + 1 size.
     * @throws Exception
     */
    public void testPageList() throws Exception {
        
        actionPerform();
        DataResult dr = (DataResult) request.getAttribute("pageList");
        int oldSize = dr.getTotalSize();
        
        Channel original = ChannelFactoryTest.createTestChannel(user);
        Errata e = ErrataFactoryTest.createTestPublishedErrata(user.getOrg().getId());
        original.addErrata(e);
        
        ChannelFactoryTest.createTestClonedChannel(original, user);
        
        actionPerform();
        dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        assertTrue(dr.getTotalSize() == oldSize + 1);
    }
    
    /**
     * This test simulates a submit where the user has asked for results for
     * a particular cloned channel. The result should be empty until we create
     * an errata that could potentially be cloned.
     * @throws Exception
     */
    public void testChannelSubmit() throws Exception {
        
        // ClonedChannel c = (ClonedChannel) ChannelFactory.lookupById(new Long(308066));
        // assertNotNull(c);
        
        // Have to run this query first , otherwise we hit a Hibernate bug 
        // where we get a WrongClassCastException
        ChannelManager.
            getChannelsWithClonableErrata(user.getOrg());
        Channel original = ChannelFactoryTest.createTestChannel(user);
        Channel clone = ChannelFactoryTest.createTestClonedChannel(original, user);
        TestUtils.saveAndFlush(original);
        TestUtils.saveAndFlush(clone);
        // clone = (ClonedChannel) TestUtils.reload(clone);
        
        
        request.addParameter("channel", "channel_" + clone.getId());
        request.addParameter(RhnAction.SUBMITTED, "true");
        actionPerform();
        DataResult dr = (DataResult) request.getAttribute("pageList");
        
        assertNotNull(dr);
        assertTrue(dr.size() == 0);
        
        Errata e = ErrataFactoryTest.createTestPublishedErrata(user.getOrg().getId());
        original.addErrata(e);
        TestUtils.saveAndFlush(original);
        TestUtils.saveAndFlush(e);
        
        actionPerform();
        dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        assertTrue(dr.size() == 1);
    }
    
    /**
     * This test simulates a submit where the user is asking for clonable
     * errata for a particular channel, and asks to be shown errata that
     * have already been cloned. We clone the errata and verify
     * that the list for the channel contains the cloned errata only
     * when we ask to see errata that have already been cloned
     * @throws Exception
     */
    public void testViewAlreadyClonedErrataForChannel() throws Exception {
        // Have to run this query first , otherwise we hit a Hibernate bug 
        // where we get a WrongClassCastException
        ChannelManager.
            getChannelsWithClonableErrata(user.getOrg());

        Channel original = ChannelFactoryTest.createTestChannel(user);
        Channel clone = ChannelFactoryTest.createTestClonedChannel(original, user);
        TestUtils.saveAndFlush(original);
        TestUtils.saveAndFlush(clone);
        
        Errata e = ErrataFactoryTest.createTestPublishedErrata(user.getOrg().getId());
        original.addErrata(e);
        
        ErrataFactory.createClone(user.getOrg(), e);
        
        request.addParameter("channel", "channel_" + clone.getId());
        request.addParameter(RhnAction.SUBMITTED, "true");
        actionPerform();
        DataResult dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        assertTrue(dr.size() == 0);
        
        request.addParameter("channel", "channel_" + clone.getId());
        request.addParameter(RhnAction.SUBMITTED, "true");
        request.addParameter(CloneErrataActionHelper.SHOW_ALREADY_CLONED, "true");
        actionPerform();
        dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        assertTrue(dr.size() == 1);
    }
    
    /**
     * This test simulates a submit where the user is asking for clonable
     * errata for all channels, and asks to be shown errata that
     * have already been cloned. We clone an errata and verify
     * that the list contains MORE errata (as that's all we can guarantee)
     * when we ask for errata that have already been cloned
     * @throws Exception
     */
    public void testViewAlreadyClonedErrataForAll() throws Exception {
        // Have to run this query first , otherwise we hit a Hibernate bug 
        // where we get a WrongClassCastException
        ChannelManager.
            getChannelsWithClonableErrata(user.getOrg());

        Channel original = ChannelFactoryTest.createTestChannel(user);
        ChannelFactoryTest.createTestClonedChannel(original, user);
        
        Errata e = ErrataFactoryTest.createTestPublishedErrata(user.getOrg().getId());
        original.addErrata(e);
        
        ErrataFactory.createClone(user.getOrg(), e);
        
        request.addParameter("channel", CloneErrataActionHelper.ANY_CHANNEL);
        request.addParameter(RhnAction.SUBMITTED, "true");
        actionPerform();
        DataResult dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        int oldSize = dr.getTotalSize();
        
        request.addParameter("channel", CloneErrataActionHelper.ANY_CHANNEL);
        request.addParameter(RhnAction.SUBMITTED, "true");
        request.addParameter(CloneErrataActionHelper.SHOW_ALREADY_CLONED, "true");
        actionPerform();
        dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        assertTrue(dr.getTotalSize() > oldSize);
    }
    
    public void testBadSubmit() throws Exception {
        
        request.addParameter("channel", "we've_got_snakes_on_a_plane");
        actionPerform();
        verifyForward("error");
    }
}
