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
package com.redhat.rhn.frontend.events.test;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.events.UpdateErrataCacheAction;
import com.redhat.rhn.frontend.events.UpdateErrataCacheEvent;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.errata.cache.test.ErrataCacheManagerTest;
import com.redhat.rhn.manager.rhnpackage.test.PackageManagerTest;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.TestUtils;

import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class UpdateErrataCacheEventTest extends BaseTestCaseWithUser {


    public void testUpdateCache() throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);
        for (int i = 0; i < 10; i++) {
            ErrataCacheManagerTest.createServerNeedintErrataCache(user);
        }

        UpdateErrataCacheEvent evt =
            new UpdateErrataCacheEvent(UpdateErrataCacheEvent.TYPE_ORG);
        evt.setOrgId(user.getOrg().getId());

        UpdateErrataCacheAction action = new UpdateErrataCacheAction();
        action.execute(evt);
    }

    public void testUpdateCacheForChannel() throws Exception {
        Channel c = ChannelTestUtils.createTestChannel(user);
        Channel c2 = ChannelTestUtils.createTestChannel(user);
        Server s2 = ServerFactoryTest.createTestServer(user);

        user.addRole(RoleFactory.ORG_ADMIN);
        Map testobjects = ErrataCacheManagerTest.
            createServerNeededPackageCache(user, ErrataFactory.ERRATA_TYPE_BUG);
        Errata e = (Errata) testobjects.get("errata");
        Server s = (Server) testobjects.get("server");
        Package p = (Package) testobjects.get("package");
        p = (Package) TestUtils.saveAndReload(p);

        Package newpackage = (Package) testobjects.get("newpackage");

        // Setup Errata
        e.addPackage(newpackage);
        e.addChannel(c);
        e.addChannel(c2);
        e = (Errata) TestUtils.saveAndReload(e);

        // Setup Channel
        c.addPackage(p);
        c.addPackage(newpackage);
        c2.addPackage(p);
        c2.addPackage(newpackage);
        ChannelFactory.save(c);
        TestUtils.flushAndEvict(c);
        ChannelFactory.save(c2);
        TestUtils.flushAndEvict(c2);


        // Setup System
        PackageManagerTest.associateSystemToPackage(s, p);
        PackageManagerTest.associateSystemToPackage(s2, p);
        SystemManager.subscribeServerToChannel(user, s, c);
        SystemManager.subscribeServerToChannel(user, s2, c2);

        // Delete so we can actually test to see if the event does something
        ErrataCacheManager.deleteNeededErrataCache(s.getId(),
                e.getId());

        // Recalc the cache
        UpdateErrataCacheEvent evt =
            new UpdateErrataCacheEvent(UpdateErrataCacheEvent.TYPE_CHANNEL);

        List channelIds = new LinkedList();
        channelIds.add(c.getId());
        evt.setChannels(channelIds);
        evt.setOrgId(user.getOrg().getId());

        UpdateErrataCacheAction action = new UpdateErrataCacheAction();
        action.execute(evt);


        // SystemManager.unsubscribeServerFromChannel(s2, c2);
        // Remove c2 from errata
        Set newchannels = new HashSet();
        newchannels.add(c);
        e = ErrataFactory.lookupById(e.getId());
        e.setChannels(newchannels);



        TestUtils.saveAndFlush(e);

        channelIds.clear();
        channelIds.add(c2.getId());
        evt.setChannels(channelIds);
        action.execute(evt);



    }
}
