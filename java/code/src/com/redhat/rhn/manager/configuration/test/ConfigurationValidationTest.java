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
package com.redhat.rhn.manager.configuration.test;

import com.redhat.rhn.manager.configuration.ConfigurationValidation;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * ConfigurationValidationTest
 * @version $Rev$
 */
public class ConfigurationValidationTest extends RhnBaseTestCase {

    public void testValidatePath() {
        assertEquals(0, ConfigurationValidation.
                            validatePath("/etc/foo").getErrors().size());
        assertEquals(1, ConfigurationValidation.
                            validatePath("etc/foo").getErrors().size());
        assertEquals(1, ConfigurationValidation.
                            validatePath("/etc/foo/").getErrors().size());
        assertEquals(2, ConfigurationValidation.
                            validatePath("etc/foo/").getErrors().size());
        assertEquals(1, ConfigurationValidation.
                            validatePath("/etc/../foo").getErrors().size());
        assertEquals(3, ConfigurationValidation.
                            validatePath("etc/../foo/").getErrors().size());
    }

    public void testValidateContent() {
        assertEquals(0, ConfigurationValidation.
                             validateContent("", "{@", "@}").getErrors().size());
        assertEquals(0, ConfigurationValidation.
                validateContent("{@ @}", "{@", "@}").getErrors().size());
        assertEquals(1, ConfigurationValidation.validateContent("{@ foo.bar.blech @}",
                "{@", "@}").getErrors().size());
        assertEquals(1, ConfigurationValidation.validateContent("{@ ( bar ) = blech @}",
                "{@", "@}").getErrors().size());
        assertEquals(0, ConfigurationValidation.validateContent("{@ rhn.system.foo @}",
                "{@", "@}").getErrors().size());
        assertEquals(0, ConfigurationValidation.validateContent("{@ rhn.system.foo() @}",
                "{@", "@}").getErrors().size());
        assertEquals(1, ConfigurationValidation.validateContent("{@ rhn.system.foo( @}",
                "{@", "@}").getErrors().size());
        assertEquals(0, ConfigurationValidation.
                        validateContent("{@ rhn.system.foo( bar ) @}", "{@", "@}").
                                getErrors().size());
        assertEquals(0, ConfigurationValidation.validateContent(
                "{@ rhn.system.foo( bar ) = @}", "{@", "@}").getErrors().size());
        assertEquals(0, ConfigurationValidation.validateContent(
                "{@ rhn.system.foo( bar ) = blech @}", "{@", "@}").getErrors().size());

        assertEquals(0, ConfigurationValidation.validateContent(
                "{@ rhn.system.foo( bar- ) = blech @}", "{@", "@}").getErrors().size());

        assertEquals(0, ConfigurationValidation.validateContent(
                    "{@ rhn.system.foo(bar) @} {@ rhn.system.foo(bar) @}", "{@", "@}").
                            getErrors().size());
        assertEquals(0, ConfigurationValidation.validateContent(
                "{@ rhn.system.foo(bar) @}\n{@ rhn.system.foo(bar) @}", "{@", "@}").
                            getErrors().size());
        assertEquals(0, ConfigurationValidation.validateContent(
                "{@\nrhn.system.foo(\nbar\n) @}\n{@ rhn.system.foo\n(bar)\n @}",
                "{@", "@}").getErrors().size());

        assertEquals(2, ConfigurationValidation.validateContent(
                "{@\nack.foo(\nbar\n) @}\n{@ kaff.foo\n(bar)\n @}", "{@", "@}").
                            getErrors().size());
    }

    public void testValidUGID() {
        String id = "12345";
        assertTrue(ConfigurationValidation.validateUGID(id));
        id = null;
        assertFalse(ConfigurationValidation.validateUGID(id));
        id = "";
        assertFalse(ConfigurationValidation.validateUGID(id));
        id = "-567";
        assertFalse(ConfigurationValidation.validateUGID(id));
        id = "root";
        assertFalse(ConfigurationValidation.validateUGID(id));
        id = "0x0A";
        assertFalse(ConfigurationValidation.validateUGID(id));
    }

    public void testValidateUserOrGroup() {
        String name = "root";
        assertTrue(ConfigurationValidation.validateUserOrGroup(name));
        name = "root_-name";
        assertTrue(ConfigurationValidation.validateUserOrGroup(name));
        name = null;
        assertFalse(ConfigurationValidation.validateUserOrGroup(name));
        name = "";
        assertFalse(ConfigurationValidation.validateUserOrGroup(name));
        name = "0root";
        assertFalse(ConfigurationValidation.validateUserOrGroup(name));
        name = "root*";
        assertFalse(ConfigurationValidation.validateUserOrGroup(name));
    }
}
