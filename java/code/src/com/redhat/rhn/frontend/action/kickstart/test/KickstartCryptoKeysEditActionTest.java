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

import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.crypto.CryptoKey;
import com.redhat.rhn.domain.kickstart.crypto.test.CryptoTest;
import com.redhat.rhn.frontend.action.kickstart.KickstartCryptoKeysSubmitAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.TestUtils;

/**
 * KickstartKeysEditActionTest
 * @version $Rev: 1 $
 */
public class KickstartCryptoKeysEditActionTest extends BaseKickstartEditTestCase {

    private CryptoKey key;

    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();
        key = CryptoTest.createTestKey(user.getOrg());
        KickstartFactory.saveCryptoKey(key);
        TestUtils.flushAndEvict(key);
    }

    public void testSetupExecute() throws Exception {
        setRequestPathInfo("/kickstart/KickstartCryptoKeysList");
        actionPerform();
        assertNotNull(request.getAttribute(RequestContext.KICKSTART));
    }

    public void testSubmitExecute() throws Exception {
        addSelectedItem(key.getId());
        addDispatchCall(KickstartCryptoKeysSubmitAction.UPDATE_METHOD);
        setRequestPathInfo("/kickstart/KickstartCryptoKeysListSubmit");
        assertEquals(0, ksdata.getCryptoKeys().size());
        actionPerform();
        assertEquals(1, ksdata.getCryptoKeys().size());
    }



}

