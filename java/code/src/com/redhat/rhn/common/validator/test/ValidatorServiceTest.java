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
package com.redhat.rhn.common.validator.test;

import com.redhat.rhn.common.validator.Validator;
import com.redhat.rhn.common.validator.ValidatorService;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import java.util.Date;

/**
 * ValidatorTest - Test that the ValidatorService functions properly
 * @version $Rev$
 */
public class ValidatorServiceTest extends RhnBaseTestCase {

    private Validator validator;

    public void setUp() throws Exception {
        disableLocalizationServiceLogging();
        validator = Validator.getInstance(TestUtils.findTestData("TestObject.xsd"));
    }

    public void testValidateObject() throws Exception {
        TestObject to = new TestObject();
        to.setStringField("somevalue");
        to.setDateField(new Date());
        to.setLongField(new Long(10));
        to.setSecondStringField("someothervalue");
        to.setNumberString("1");
        to.setAsciiString("asciivalue");
        to.setUsernameString("usernamevalue");
        to.setPosixString("posixvalue");
        to.setTwoCharField("12");

        assertTrue(
            ValidatorService.getInstance().validateObject(to, validator).isEmpty());
    }

    /** Test the method on the ValidationService where we let the
     * service attempt to find the XSD associated with the object
     * in the same directory.
     * @throws Exception
     */
    public void testValidateObjectNoValidator() throws Exception {
        TestObject to = new TestObject();
        to.setStringField("somevalue");
        to.setDateField(new Date());
        to.setLongField(new Long(10));
        to.setSecondStringField("someothervalue");
        to.setNumberString("1");
        to.setAsciiString("asciivalue");
        to.setUsernameString("usernamevalue");
        to.setPosixString("posixvalue");
        to.setTwoCharField("12");

        assertTrue(
            ValidatorService.getInstance().validateObject(to).isEmpty());
    }


    public void testInvalidObject() throws Exception {
        TestObject to = new TestObject();
        to.setStringField("somevaluelkjajsjlfdlkjaslkjdf0980934098234");
        to.setLongField(new Long(10));
        to.setSecondStringField("someothervalue");

        assertNotNull(
            ValidatorService.getInstance().validateObject(to, validator));
    }

    /**
     * {@inheritDoc}
     */
    protected void tearDown() throws Exception {
        // TODO Auto-generated method stub
        super.tearDown();
        enableLocalizationServiceLogging();
    }


}


