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
package com.redhat.rhn.frontend.action.common.test;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.token.test.ActivationKeyTest;
import com.redhat.rhn.frontend.action.kickstart.ActivationKeysSubmitAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.taglibs.ListDisplayTag;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;

/**
 * BaseSetOperateOnDiffActionTest
 * @version $Rev$
 */
public class BaseSetOperateOnDiffActionTest extends RhnMockStrutsTestCase {

    // We use activation keys <-> to kickstart profile to test this.
    // I wanted to make sure we had a specific test class that was tied
    // to this baseclass since its complex and needs tests geared towards
    // it.
    public void testSelectAll() throws Exception {

        KickstartData ksdata = KickstartDataTest.createKickstartWithOptions(user.getOrg());
        for (int i = 0; i < 5; i++) {
            ActivationKey key = ActivationKeyFactory.createNewKey(user, 
                    TestUtils.randomString());
            ActivationKeyFactory.save(key);
            TestUtils.flushAndEvict(key);
        }
        assertTrue((ksdata.getDefaultRegTokens() == null || 
                ksdata.getDefaultRegTokens().size() == 0));
        setRequestPathInfo("/kickstart/ActivationKeysSubmit");
        addSelectedItem(ActivationKeyTest.createTestActivationKey(user, 
                ServerFactoryTest.createTestServer(user)).getId());
        addDispatchCall(ListDisplayTag.SELECT_ALL_KEY);
        actionPerform();
        assertTrue(
            RhnSetDecl.KICKSTART_ACTIVATION_KEYS.get(user).getElements().size() >= 5); 
        clearRequestParameters();
        addRequestParameter(RequestContext.KICKSTART_ID, ksdata.getId().toString());
        addDispatchCall(ActivationKeysSubmitAction.UPDATE_METHOD);
        actionPerform();
        verifyActionMessage("kickstart_activation_keys.added");
        assertTrue((ksdata.getDefaultRegTokens() != null && 
                ksdata.getDefaultRegTokens().size() > 0));

    }
}
