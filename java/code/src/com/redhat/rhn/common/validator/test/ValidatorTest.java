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

import com.redhat.rhn.common.validator.Constraint;
import com.redhat.rhn.common.validator.DataConverter;
import com.redhat.rhn.common.validator.Validator;
import com.redhat.rhn.testing.TestUtils;

import java.util.Date;

import junit.framework.TestCase;

/**
 * ValidatorTest
 * @version $Rev$
 */
public class ValidatorTest extends TestCase {
    
    private Validator validator;
    
    public void setUp() throws Exception {
        TestUtils.disableLocalizationLogging();
        validator = Validator.getInstance(TestUtils.findTestData("TestObject.xsd"));
    }
    
    /**
     * {@inheritDoc}
     */
    protected void tearDown() throws Exception {
        TestUtils.enableLocalizationLogging();
        super.tearDown();
    }



    public void testDataConverter() throws Exception {
        DataConverter dc = DataConverter.getInstance();
        assertNotNull(dc.getJavaType("date"));
        assertNotNull(dc.getJavaType("string"));
        assertNotNull(dc.getJavaType("long"));
        assertNotNull(dc.getSchemaType("Date"));
        assertNotNull(dc.getSchemaType("String"));
        assertNotNull(dc.getSchemaType("Long"));
        
        
    }
    
    public void testGetConstraints() {
        assertTrue(validator.getConstraints().size() > 0);
        Object constraint = validator.getConstraints().get(0);
        assertTrue(constraint instanceof Constraint);
    }
    
    public void testNullValue() throws Exception {
        TestObject to = new TestObject();
        assertNotNull(validator.isValid("stringField", to));
    }
    
    public void testStringLength() throws Exception {
        TestObject to = new TestObject();
        to.setStringField("short");
        assertNull(validator.isValid("stringField", to));
        to.setStringField("somethingthatistoolongandshouldfail");
        assertNotNull(validator.isValid("stringField", to));
        to.setStringField("");
        assertNotNull(validator.isValid("stringField", to));
        to.setStringField("    ");
        assertNotNull(validator.isValid("stringField", to));
        to.setTwoCharField("it");
        assertNull(validator.isValid("twoCharField", to));
    }
    
    public void testASCIIString() throws Exception {
        TestObject to = new TestObject();
        to.setAsciiString("shughes_login");
        assertNull(validator.isValid("asciiString", to));
        to.setAsciiString("機能拡張を");
        assertNotNull(validator.isValid("asciiString", to));
    }

    public void testUserNameString() throws Exception {
        TestObject to = new TestObject();

        // bad user names
        to.setUsernameString("foo&user");
        assertNotNull(validator.isValid("usernameString", to));
        to.setUsernameString("joe+page");
        assertNotNull(validator.isValid("usernameString", to));
        to.setUsernameString("joe user");
        assertNotNull(validator.isValid("usernameString", to));
        to.setUsernameString("10%users");
        assertNotNull(validator.isValid("usernameString", to));
        to.setUsernameString("joe'suser");
        assertNotNull(validator.isValid("usernameString", to));
        to.setUsernameString("`eval`");
        assertNotNull(validator.isValid("usernameString", to));
        to.setUsernameString("joe=page");
        assertNotNull(validator.isValid("usernameString", to));
        to.setUsernameString("foo#user");
        assertNotNull(validator.isValid("usernameString", to));
        to.setUsernameString("joe\"user");
        assertNotNull(validator.isValid("usernameString", to));
        to.setUsernameString("機能拡張を"); 
        assertNotNull(validator.isValid("usernameString", to));
        to.setUsernameString("shughes login"); 
        assertNotNull(validator.isValid("usernameString", to));
        to.setUsernameString("shughes%login"); 
        assertNotNull(validator.isValid("usernameString", to));
        to.setUsernameString(" shughes"); 
        assertNotNull(validator.isValid("usernameString", to));

        // good user names
        to.setUsernameString("john.cusack@foobar.com");
        assertNull(validator.isValid("usernameString", to));
        to.setUsernameString("a$user");
        assertNull(validator.isValid("usernameString", to));
        to.setUsernameString("!@$^*()-_{}[]|\\:;?");
        assertNull(validator.isValid("usernameString", to));
        to.setUsernameString("/usr/bin");
        assertNull(validator.isValid("usernameString", to));
        to.setUsernameString("shughes_login");
        assertNull(validator.isValid("usernameString", to));
        to.setUsernameString("shughes@redhat.com");
        assertNull(validator.isValid("usernameString", to));
        to.setUsernameString("/shughes_login");
        assertNull(validator.isValid("usernameString", to));
        to.setUsernameString("/\\/\\ark");
        assertNull(validator.isValid("usernameString", to));

    }
    
    public void testPosixUsername() {
        TestObject to = new TestObject();

        // valid user names
        to.setPosixString("ab");
        assertNull(validator.isValid("posixString", to));
        to.setPosixString("AB");
        assertNull(validator.isValid("posixString", to));
        to.setPosixString("09");
        assertNull(validator.isValid("posixString", to));
        to.setPosixString("aA0");
        assertNull(validator.isValid("posixString", to));
        to.setPosixString("_-.");
        assertNull(validator.isValid("posixString", to));
        to.setPosixString("a_B-0.Z");
        assertNull(validator.isValid("posixString", to));
        to.setPosixString("shughes_login");
        assertNull(validator.isValid("posixString", to));
        
        // Should fail
        to.setPosixString("-ab");
        assertNotNull(validator.isValid("posixString", to));

        to.setPosixString("john.cusack@foobar.com");
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("a$user");
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("!@$^*()-_{}[]|\\:;?");
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("/usr/bin");
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("shughes@redhat.com");
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("/shughes_login");
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("/\\/\\ark");
        assertNotNull(validator.isValid("posixString", to));

        to.setPosixString("foo&user");
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("joe+page");
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("joe user");
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("10%users");
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("joe'suser");
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("`eval`");
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("joe=page");
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("foo#user");
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("joe\"user");
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("機能拡張を"); 
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("shughes login"); 
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString("shughes%login"); 
        assertNotNull(validator.isValid("posixString", to));
        to.setPosixString(" shughes"); 
        assertNotNull(validator.isValid("posixString", to));
    }
    
    public void testDateField() throws Exception {
        TestObject to = new TestObject();
        to.setDateField(new Date());
        assertNull(validator.isValid("dateField", to));
    }
    
    public void testLongField() throws Exception {

        TestObject to = new TestObject();
        to.setLongField(new Long(10));
        assertNull(validator.isValid("longField", to));
        to.setLongField(new Long(100));
        assertNotNull(validator.isValid("longField", to));
        
        assertNotNull(validator.isValid("numberString", to));
        to.setNumberString("0.5");
        assertNotNull(validator.isValid("numberString", to));
        to.setNumberString(".5");
        assertNotNull(validator.isValid("numberString", to));
        to.setNumberString("1");
        assertNull(validator.isValid("numberString", to));
    }
    
    /** TODO: Implement the multi-value fields */
    public void testMultiValueField() throws Exception { 
        TestObject to = new TestObject();
        to.setStringField("ZZZ");
        to.setCompoundField("something");
        assertNull(validator.isValid("compoundField", to));
        to.setStringField("XXX");
        assertNull(validator.isValid("compoundField", to));
        to.setStringField("INVALID");
        assertNull(validator.isValid("compoundField", to));
        to.setCompoundField(null);
        assertNull(validator.isValid("compoundField", to));
        to.setStringField("XXX");
        assertNotNull(validator.isValid("compoundField", to));
        // Check that the length constraints work too
        to.setCompoundField("somethingmorethan20characterslong");
        assertNotNull(validator.isValid("compoundField", to));
    }
    
    public void testRequiredIfConstraint() {
        TestObject to = new TestObject();
        //init both to empty strings
        to.setStringField("");
        to.setSecondStringField("");
        
        // Make sure that when both are null/empty, everything is ok
        assertNull(validator.isValid("secondStringField", to));

        // If the secondStringField is required if stringField is not null
        to.setStringField("foo");
        assertNotNull(validator.isValid("secondStringField", to));

        // Set both to something and it should be valid
        to.setSecondStringField("bar");
        assertNull(validator.isValid("secondStringField", to));
        
        // Since stringField isn't ZZZ or XXX this should 
        // be OK
        assertNull(validator.isValid("secondLongField", to));
        
        to.setStringField("ZZZ");
        // Now it should fail
        assertNotNull(validator.isValid("secondLongField", to));
    }
}    


