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

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.context.Context;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

import java.util.TimeZone;

/**
 * ErrataConfirmActionTest
 * @version $Rev$
 */
public class ErrataConfirmActionTest extends RhnMockStrutsTestCase {

    public void setUp() throws Exception {
        super.setUp();
        setRequestPathInfo("/systems/details/ErrataConfirm");
    }
    /**
     * Tests a good/clean operation, errata are present.
     *
     * @throws Exception
     */
    public void testExecuteConfirmed() throws Exception {
        Context ctx = Context.getCurrentContext();
        // DatePicker widget needs Context.getTimezone to return a non-null value
        // By default, Context will return a null timezone.
        ctx.setTimezone(TimeZone.getDefault());

        addDispatchCall("errataconfirm.jsp.confirm");

        addRequestParameter(DatePicker.USE_DATE, "true");
        // Create System
        Server server = ServerFactoryTest.createTestServer(user, true);

        RhnSet errata = RhnSetDecl.ERRATA.createCustom(
                                        server.getId()).get(user);

        //Fully create channels so that errata can be added to them.

        Channel channel = ChannelFactoryTest.createTestChannel(user);

        // Create a set of Errata IDs
        for (int i = 0; i < 5; i++) {
            Errata e = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
            e.addChannel(channel);
            ErrataManager.storeErrata(e);
            errata.addElement(e.getId());
            ErrataFactoryTest.updateNeedsErrataCache(
                    ((Package)e.getPackages().iterator().next()).getId(),
                    server.getId(), e.getId());
            UserFactory.save(user);
        }
        RhnSetManager.store(errata); //save the set

        addRequestParameter("sid", server.getId().toString());
        addSubmitted();
        // Execute the Action
        actionPerform();
        String forward = getActualForward();
        assertTrue(forward.contains("details/ErrataList"));
    }

    /**
     * Tests when an incomplete set of errata is passed into the action.
     * @throws Exception
     */
    public void testExecuteIncomplete() throws Exception {

        Context ctx = Context.getCurrentContext();
        // DatePicker widget needs Context.getTimezone to return a non-null value
        // By default, Context will return a null timezone.
        ctx.setTimezone(TimeZone.getDefault());


        addRequestParameter("all", "false");
        RhnSet errata = RhnSetDecl.ERRATA.get(user);
        // Create System
        Server server = ServerFactoryTest.createTestServer(user, true);

        //Fully create channels so that errata can be added to them.
        ChannelFactoryTest.createTestChannel(user);


        RhnSetManager.store(errata); //save the set

        addRequestParameter("sid", server.getId().toString());

        addSubmitted();
        addRequestParameter("dispatch", "dispatch");
        // Execute the Action
        actionPerform();
        assertTrue(getActualForward().contains("systems/errataconfirm.jsp"));
    }

}
