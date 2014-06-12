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
package com.redhat.rhn.frontend.action.keys.test;

import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.frontend.action.keys.BaseCryptoKeyEditAction;
import com.redhat.rhn.frontend.action.keys.CryptoKeyDeleteAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.crypto.CreateCryptoKeyCommand;
import com.redhat.rhn.manager.kickstart.crypto.test.CryptoKeyCommandTest;
import com.redhat.rhn.testing.RhnPostMockStrutsTestCase;

/**
 * CryptoKeyDeleteActionTest
 * @version $Rev: 1 $
 */
public class CryptoKeyDeleteActionTest extends RhnPostMockStrutsTestCase {

    private CreateCryptoKeyCommand cmd;

    public void testExecute() throws Exception {
        cmd = new CreateCryptoKeyCommand(user.getOrg());
        CryptoKeyCommandTest testObj = new CryptoKeyCommandTest();
        testObj.setupKey(cmd);
        setRequestPathInfo("/keys/CryptoKeyDelete");
        addRequestParameter(RequestContext.KEY_ID, cmd.getCryptoKey().getId().toString());
        addRequestParameter(CryptoKeyDeleteAction.SUBMITTED, Boolean.FALSE.toString());
        actionPerform();
        assertNotNull(request.getAttribute(BaseCryptoKeyEditAction.KEY));
    }

    public void testDeleteSubmit() throws Exception {
        cmd = new CreateCryptoKeyCommand(user.getOrg());
        CryptoKeyCommandTest testObj = new CryptoKeyCommandTest();
        testObj.setupKey(cmd);
        setRequestPathInfo("/keys/CryptoKeyDelete");
        addRequestParameter(RequestContext.KEY_ID, cmd.getCryptoKey().getId().toString());
        addRequestParameter(CryptoKeyDeleteAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(CryptoKeyDeleteAction.CONTENTS_EDIT, cmd.getCryptoKey().getKeyString());
        actionPerform();
        String[] keys = {"cryptokey.delete.success"};
        verifyActionMessages(keys);
        assertNull(KickstartFactory.lookupCryptoKeyById(cmd.getCryptoKey().getId(),
                                                              cmd.getCryptoKey().getOrg()));
    }
}
