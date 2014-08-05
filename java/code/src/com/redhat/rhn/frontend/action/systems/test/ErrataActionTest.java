/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.RhnPostMockStrutsTestCase;

/**
 * ErrataActionTest
 * @version $Rev$
 */
public class ErrataActionTest extends RhnPostMockStrutsTestCase {
    public void testEmptySelection() throws Exception {
        String pathInfo = "/systems/details/ErrataList";
        setRequestPathInfo(pathInfo);
        addSubmitted();
        addRequestParameter(RequestContext.DISPATCH, Boolean.toString(true));
        Server server = ServerFactoryTest.createTestServer(user, true);
        Errata e = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        Package p = e.getPackages().iterator().next();
        ErrataCacheManager.insertNeededErrataCache(server.getId(),
                e.getId(), p.getId());
        addRequestParameter(RequestContext.SID, server.getId().toString());
        actionPerform();
        assertTrue(getActualForward().indexOf("errata.jsp") > -1);

    }

    public void testSelectAll() throws Exception {
        String pathInfo = "/systems/details/ErrataList";
        setRequestPathInfo(pathInfo);
        addSubmitted();
        addRequestParameter(RequestContext.DISPATCH,
                LocalizationService.getInstance().getMessage("errata.jsp.apply"));

        // Create System
        Server server = ServerFactoryTest.createTestServer(user, true);
        RhnSet errata = RhnSetDecl.ERRATA.createCustom(
                                        server.getId()).get(user);
        //Fully create channels so that errata can be added to them.
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        channel.setChannelFamily(user.getOrg().getPrivateChannelFamily());
        ChannelFactory.save(channel);

        // Create a set of Errata IDs
        for (int i = 0; i < 5; i++) {
            Errata e = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
            e.addChannel(channel);
            ErrataManager.storeErrata(e);
            errata.addElement(e.getId());
            ErrataFactoryTest.updateNeedsErrataCache(
                    e.getPackages().iterator().next().getId(),
                    server.getId(), e.getId());
            UserFactory.save(user);
        }
        RhnSetManager.store(errata); //save the set

        addRequestParameter(RequestContext.SID, server.getId().toString());
        actionPerform();
        assertTrue(getActualForward().indexOf("ErrataConfirm") > -1);
    }

}
