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
package com.redhat.rhn.frontend.action.errata.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.errata.ChannelSetupAction;
import com.redhat.rhn.frontend.dto.ChannelOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.struts.action.ActionForward;

import java.util.Iterator;

/**
 * ChannelSetupActionTest
 * @version $Rev$
 */
public class ChannelSetupActionTest extends RhnBaseTestCase {

    /**
     * A dummy test until the other two are fixed.
     */
    public void testDummy() throws Exception {
        assertEquals(42, 42);
    }

    /**
     * This setup action will get called with an unpublished errata during the publish
     * process. We need to test that nothing is added to the user's set, the relevant
     * packages are set correctly, and that the returnvisit variable has been set.
     * @throws Exception
     */

    // This test does not properly set up the permissions to the
    // errata, because the user for the action is not the same as the
    // user for the errata.

    public void brokentTestExecuteUnpublished() throws Exception {
        ChannelSetupAction action = new ChannelSetupAction();
        ActionHelper sah = new ActionHelper();
        
        sah.setUpAction(action);
        sah.setupClampListBounds();
        
        //Create a new errata
        Errata e = ErrataFactoryTest.createTestUnpublishedErrata(UserTestUtils
                                                         .createOrg("channelTestOrg"));
        sah.getRequest().setupAddParameter("eid", e.getId().toString());
        sah.getRequest().setupAddParameter("newset", (String) null);
        sah.getRequest().setupAddParameter("returnvisit", (String) null);
        sah.getRequest().setupAddParameter("returnvisit", (String) null);
        sah.setupClampListBounds();
        ActionForward result = sah.executeAction();

        //make sure set was set
        assertNotNull(sah.getRequest().getAttribute("set"));
        assertEquals(result.getName(), "default");
        
        //get the data result back out of the request and inspect
        DataResult dr = (DataResult) sah.getRequest().getAttribute("pageList");
        assertNotNull(dr);
        Iterator itr = dr.iterator();
        while (itr.hasNext()) {
            //make sure the relevant packages were set
            ChannelOverview channel = (ChannelOverview) itr.next();
            assertNotNull(channel.getRelevantPackages());
        }
        //make sure returnvisit was set
        assertNotNull(sah.getRequest().getAttribute("returnvisit"));
        
        RequestContext requestContext = new RequestContext(sah.getRequest());
        
        //make sure set is empty
        User user = requestContext.getLoggedInUser();
        RhnSet set = RhnSetDecl.CHANNELS_FOR_ERRATA.get(user);
        assertTrue(set.isEmpty());
        
        //Set the setupdated variable to make sure we are keeping changes from the set
        User usr = requestContext.getLoggedInUser();
        RhnSet newset = RhnSetDecl.CHANNELS_FOR_ERRATA.create(usr);
        newset.addElement(new Long(42));
        newset.addElement(new Long(43));
        newset.addElement(new Long(44));
        RhnSetManager.store(newset);
        
        //setup the request
        sah.getRequest().setupAddParameter("eid", e.getId().toString());
        sah.getRequest().setupAddParameter("newset", (String) null);
        sah.getRequest().setupAddParameter("returnvisit", "true");
        sah.getRequest().setupAddParameter("returnvisit", "true");
        sah.getRequest().setupAddParameter("setupdated", "true");
        sah.setupClampListBounds();
        result = sah.executeAction();
        
        //ok, now we should have went to the db to get the newset var
        String ns = (String) sah.getRequest().getAttribute("newset");
        assertNotNull(ns);
        assertTrue(ns.length() > 2); // greater than '[]'
    }
    
    /**
     * This setup action will get called with a published errata from the channels edit
     * tab that appears in the details nav for a published errata. We need to make sure
     * that the users set gets initialized to the channels that are in the errata when
     * the user first visits the page.
     * @throws Exception
     */
    // This test does not properly set up the permissions to the
    // errata, because the user for the action is not the same as the
    // user for the errata or the channel.
    public void brokenTestExecutePublished() throws Exception {
        ChannelSetupAction action = new ChannelSetupAction();
        ActionHelper sah = new ActionHelper();
        
        sah.setUpAction(action);
        sah.setupClampListBounds();
        
        //Create a new errata
        Errata e = ErrataFactoryTest.createTestPublishedErrata(UserTestUtils
                                        .createOrg("channelTestOrg"));
        //make sure we have a channel for the errata
        Channel c1 = ChannelFactoryTest.createTestChannel();
        e.addChannel(c1);
        ErrataManager.storeErrata(e);
        //setup the request object
        sah.getRequest().setupAddParameter("eid", e.getId().toString());
        sah.getRequest().setupAddParameter("newset", (String) null);
        sah.getRequest().setupAddParameter("returnvisit", (String) null);
        sah.getRequest().setupAddParameter("returnvisit", (String) null);
        sah.executeAction();
        
        RequestContext requestContext = new RequestContext(sah.getRequest());
        
        //make sure set is not empty
        User user = requestContext.getLoggedInUser();
        RhnSet set = RhnSetDecl.CHANNELS_FOR_ERRATA.get(user);
        assertFalse(set.isEmpty());
    }
}
