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
package com.redhat.rhn.frontend.struts.test;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.frontend.action.LoginAction;
import com.redhat.rhn.frontend.action.configuration.channel.ChannelOverviewAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;

import org.apache.struts.action.ActionErrors;

/**
 * RhnHelperTest - test our RhnHelper class
 * @version $Rev$
 */
public class RhnValidationHelperTest extends RhnBaseTestCase {

    /**
     * Test StringsToActionErrors
     */
     public void testValidatorErrorToActionMessages() throws Exception {
        ValidatorError[] errors = new ValidatorError[3];
        errors[0] = new ValidatorError("error 1", "someval");
        errors[1] = new ValidatorError("error 2", "someval1");
        errors[2] = new ValidatorError("error 3", "someval2");
        ActionErrors am = RhnValidationHelper.validatorErrorToActionErrors(errors);
        assertNotNull(am);
        assertTrue(am.size() == 3);
     }

     public void testValidateDynaActionForm() throws Exception {
         LoginAction la = new LoginAction();
         RhnMockDynaActionForm form = new RhnMockDynaActionForm();
         form.setFormName("loginForm");
         form.set("username", "");
         form.set("password", "somepassword");
         assertNotNull(RhnValidationHelper.validateDynaActionForm(la, form));
         form.set("username", "something");
         assertTrue(RhnValidationHelper.validateDynaActionForm(la, form).isEmpty());
     }

     public void testValidateDynaActionFormPathed() throws Exception {
         ChannelOverviewAction coa = new ChannelOverviewAction();
         RhnMockDynaActionForm form = new RhnMockDynaActionForm();
         form.setFormName("channelOverviewForm");
         form.set("cofName"        , "testName");
         form.set("cofLabel"       , "testLabel");
         form.set("cofDescription" , "This is a description");
         form.set("editing"        , Boolean.TRUE);
         form.set("creating"       , Boolean.FALSE);
         form.set("submitted"      , Boolean.TRUE);
         assertTrue(
                 RhnValidationHelper.validateDynaActionForm(
                         coa.getClass(), form, null,
                         "/com/redhat/rhn/frontend/action/configuration/channel/" +
                         "validation/channelOverviewForm.xsd").isEmpty());
     }

     public void testFailedValidation() throws Exception {
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest();
        RhnValidationHelper.setFailedValidation(request);
        assertTrue(RhnValidationHelper.getFailedValidation(request));
        request = new RhnMockHttpServletRequest();
        assertFalse(RhnValidationHelper.getFailedValidation(request));

     }
}

