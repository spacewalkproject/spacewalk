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

import com.redhat.rhn.domain.user.Address;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.user.EditAddressSetupAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;

/**
 * EditAddressActionTest
 * @version $Rev: 694 $
 */
public class EditAddressSetupActionTest extends RhnBaseTestCase {

    public void testPerformExecuteWithAddr() throws Exception {
        EditAddressSetupAction action = new EditAddressSetupAction();
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        sah.getRequest().setupAddParameter("type", Address.TYPE_MARKETING);

        User user = sah.getUser();
        user.setPhone("555-1212");
        user.setFax("555-1212");

        setupExpectations(sah.getForm(), user);
        sah.executeAction();

        assertNotNull(sah.getForm().get("uid"));
        sah.getForm().verify();
    }

    private void setupExpectations(RhnMockDynaActionForm form, User user) {
        form.addExpectedProperty("address1", user.getAddress1());
        form.addExpectedProperty("address2", user.getAddress2());
        form.addExpectedProperty("phone", user.getPhone());
        form.addExpectedProperty("fax", user.getFax());
        form.addExpectedProperty("city", user.getCity());
        form.addExpectedProperty("state", user.getState());
        form.addExpectedProperty("country", user.getCountry());
        form.addExpectedProperty("zip", user.getZip());

    }



}
