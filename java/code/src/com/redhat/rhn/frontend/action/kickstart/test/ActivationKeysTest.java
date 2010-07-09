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
package com.redhat.rhn.frontend.action.kickstart.test;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.token.TokenFactory;
import com.redhat.rhn.domain.token.test.ActivationKeyTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.kickstart.ActivationKeysSubmitAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.TestUtils;

/**
 * ActivationKeysTest - test for ActivationKeys lists
 * @version $Rev$
 */
public class ActivationKeysTest extends BaseKickstartEditTestCase {

    public void testSetupExecute() throws Exception {
        addKeysToKickstartData(user, ksdata);
        setRequestPathInfo("/kickstart/ActivationKeys");
        actionPerform();
        assertNotNull(request.getAttribute(RequestContext.KICKSTART));

    }

    public void testSubmit() throws Exception {
        addDispatchCall(ActivationKeysSubmitAction.UPDATE_METHOD);
        addKeysToKickstartData(user, ksdata);
        setRequestPathInfo("/kickstart/ActivationKeysSubmit");
        addSelectedItem(ActivationKeyTest.createTestActivationKey(user,
                ServerFactoryTest.createTestServer(user)).getId());
        actionPerform();
        String[] msgs = {"kickstart_activation_keys.added",
                "kickstart_activation_keys.removed"};
        verifyActionMessages(msgs);
    }


    public static ActivationKey addKeysToKickstartData(User user,
            KickstartData ksdata) throws Exception {
        ActivationKey key = ActivationKeyFactory.createNewKey(user, "some key");
        ActivationKeyFactory.save(key);
        key = (ActivationKey) TestUtils.reload(key);
        Token t = TokenFactory.lookupById(key.getId());
        ksdata.addDefaultRegToken(t);
        return key;
    }

}
