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
package com.redhat.rhn.frontend.action.systems.provisioning.kickstart.test;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.kickstart.test.KickstartSessionTest;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.rhnpackage.profile.test.ProfileTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;

/**
 * BaseSessionTestCase
 * @version $Rev$
 */
public class BaseSessionTestCase extends RhnMockStrutsTestCase {
    
    protected KickstartSession sess;
    protected Server s;
    
    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();
        KickstartData k = KickstartDataTest.createKickstartWithOptions(user.getOrg());
        
        sess = KickstartSessionTest.createKickstartSession(k, user);
        s = sess.getOldServer();
        addRequestParameter(RequestContext.SID, 
                s.getId().toString());
        
        Action a = ActionFactoryTest.createAction(user, 
                ActionFactory.TYPE_KICKSTART_INITIATE);
        sess.setAction(a);
        
        sess = KickstartSessionTest.addHistory(sess);
        Profile p  = ProfileTest.createTestProfile(user, 
                k.getKickstartDefaults().getKstree().getChannel());
        sess.setServerProfile(p);
        TestUtils.saveAndFlush(sess);
        KickstartFactory.saveKickstartSession(sess);
        sess = (KickstartSession) TestUtils.reload(sess);
    }

    
    
}
