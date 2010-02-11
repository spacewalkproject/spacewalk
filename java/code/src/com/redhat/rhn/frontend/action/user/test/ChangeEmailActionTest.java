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
package com.redhat.rhn.frontend.action.user.test;

import com.redhat.rhn.common.messaging.test.MockMail;
import com.redhat.rhn.frontend.action.user.ChangeEmailAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

/**
 * ChangeEmailActionTest
 * @version $Rev$
 */
public class ChangeEmailActionTest extends RhnBaseTestCase {

    private MockMail mailer = new MockMail();

    public void testPerformExecute() throws Exception {

        mailer.setExpectedSendCount(2);


        ChangeEmailAction action =
            new ChangeEmailAction();

        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action, "updated");
        sah.getRequest().setRequestURL("foo");
        sah.getForm().set("email", "somethingDifferent@redhat.com");
        TestUtils.enableLocalizationDebugMode();
        sah.executeAction();

        TestUtils.disableLocalizationDebugMode();

        sah.getRequest().setupAddParameter("uid", sah.getUser().getId().toString());
        sah.getForm().set("email", "differentEmailTest@redhat.com");
        sah.executeAction();

    }

}
