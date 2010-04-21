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
package com.redhat.rhn.manager.user.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.conf.UserDefaults;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.user.UpdateUserCommand;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.lang.StringUtils;

/**
 * UpdateUserCommandTest
 * @version $Rev$
 */
public class UpdateUserCommandTest extends RhnBaseTestCase {

    private UpdateUserCommand command;
    
    public void setUp() {
        Long oid = UserTestUtils.createOrg("testOrg");
        User user = UserTestUtils.createUser("testUser", oid);
        command = new UpdateUserCommand(user);
    }
    
    public void testLongNames() {
        int maxPassword = UserDefaults.get().getMaxPasswordLength();
        int emailLength = UserDefaults.get().getMaxEmailLength();

        Config.get().setString(UserDefaults.MAX_PASSWORD_LENGTH, String.valueOf(5));
        Config.get().setString(UserDefaults.MAX_EMAIL_LENGTH, String.valueOf(5));
        

        String invalidPassword = "password";
        String invalidEmail   = "foobar@foobar.com";
        //Test invalid values

        command.setEmail(invalidEmail);
        assertCommandThrows(IllegalArgumentException.class, command);
        command.setPassword(invalidPassword);
        assertCommandThrows(IllegalArgumentException.class, command);

        Config.get().setString(UserDefaults.MAX_PASSWORD_LENGTH, 
                                        String.valueOf(maxPassword));
        Config.get().setString(UserDefaults.MAX_EMAIL_LENGTH, String.valueOf(emailLength));
        
    }    
    
    public void testPartialUpdate() {
        command.setEmail("50cent@pimpville.com");
        command.setFirstNames("beetle juice");
        User user = command.updateUser();
        assertNotNull(user);
        assertEquals("50cent@pimpville.com", user.getEmail());
        assertEquals("beetle juice", user.getFirstNames());
    }
    
    public void testInvalidEmail() {
        command.setPassword("validP@a$$word");
        
        command.setEmail("jesusrredhat.com");
        assertCommandThrows(IllegalArgumentException.class, command);
        
        command.setEmail(null);
        assertCommandThrows(IllegalArgumentException.class, command);
        
        command.setEmail("");
        assertCommandThrows(IllegalArgumentException.class, command);
    }
    
    public void testInvalidPassword() {
        command.setEmail("jesusr@redhat.com");

        command.setPassword("");
        assertCommandThrows(IllegalArgumentException.class, command);
        
        command.setPassword(null);
        assertCommandThrows(IllegalArgumentException.class, command);
        
        // 65 > maxlen
        command.setPassword(
            "12345678901234567890123456789012345678901234567890123456789012345");
        assertCommandThrows(IllegalArgumentException.class, command);
        
        // minlen - 1
        command.setPassword("1234");
        assertCommandThrows(IllegalArgumentException.class, command);
    }
    
    public void testNullPassword() {
        try {
            command.setPassword(null);
        }
        catch (NullPointerException expected) {
            // expected
        }
    }
    
    public void testValidEmail() {
        command.setPassword("valid_password");
        
        assertEmail("jesusr@redhat.com", command);
        assertEmail("foobar@rhn.redhat.com", command);
        assertEmail("jmrodri@transam", command);
    }
    
    public void testValidPassword() {
        command.setEmail("jesusr@redhat.com");
        // = maxlen
        assertPassword(StringUtils.repeat("a", UserDefaults.get().
                getMinPasswordLength()), command);        
        // = maxlen
        assertPassword(StringUtils.repeat("a", UserDefaults.get().
                getMaxPasswordLength()), command);
        
        // random string
        String randomPassword = TestUtils.randomString();
        if (randomPassword.length() > 64) {
            randomPassword = randomPassword.substring(0, 64);
        }

        assertPassword(randomPassword, command);
        assertPassword("Th1$_i5-V@Lid", command);
    }
    
    public void testPrefix() {
        command.setPrefix("Miss");
        User user = command.updateUser();
        assertNotNull(user);
        assertEquals("Miss", user.getPrefix());
        
        command.setPrefix("Miss.");
        assertCommandThrows(IllegalArgumentException.class, command);
        
        command.setPrefix("Master of my Domain");
        assertCommandThrows(IllegalArgumentException.class, command);
        
        command.setPrefix("King");
        assertCommandThrows(IllegalArgumentException.class, command);
    }
    
    private void assertPassword(String password, UpdateUserCommand cmd) {
        cmd.setPassword(password);
        User user = cmd.updateUser();
        assertNotNull(user);
        
        // can't do this if we've encrypted the passwords
        if (!Config.get().getBoolean(ConfigDefaults.WEB_ENCRYPTED_PASSWORDS)) {
            String savedPassword = user.getPassword();
            user.setPassword(password);
            assertEquals(savedPassword, user.getPassword());
        }
    }
    
    private void assertEmail(String email, UpdateUserCommand cmd) {
        cmd.setEmail(email);
        User user = cmd.updateUser();
        assertNotNull(user);
        assertEquals(email, user.getEmail());
    }
    
    private void assertCommandThrows(Class expectedEx, UpdateUserCommand cmd) {
        try {
            cmd.updateUser();
            fail("Expected [" + expectedEx.getName() + "]");
        }
        catch (Exception e) {
            assertTrue("Expected [" + expectedEx.getName() + "]",
                    expectedEx.isInstance(e));
        }
    }

    public void testValidatePasswordHasTabCharacter() throws Exception {
        command.setEmail("bilbo@baggins.com");
        command.setPassword("aaaaa\tb");

        try {
            command.updateUser();
            fail();
        }
        catch (IllegalArgumentException e) {
            //expected
        }
    }

    public void testValidatePasswordHasNewlineCharacter() throws Exception {
        command.setEmail("bilbo@baggins.com");
        command.setPassword("aaaaa\nb");

        try {
            command.updateUser();
            fail();
        }
        catch (IllegalArgumentException e) {
            //expected
        }
    }
}
