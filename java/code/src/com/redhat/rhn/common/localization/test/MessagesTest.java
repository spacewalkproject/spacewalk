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

package com.redhat.rhn.common.localization.test;

import com.redhat.rhn.common.localization.XmlMessages;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.Locale;

/**
 * Test for {@link XmlMessages}.
 * @version $Rev$
 */
public class MessagesTest extends RhnBaseTestCase {
    private String getMessage;
    private String germanMessage;
    private String oneArg;
    private String twoArg;
    private String threeArg;
    private String quoteMsg;
    private String html;
    private Class clazz;
    private Locale locale;

    /** Constructor
     * @param name test name
     */
    public MessagesTest(final String name) {
        super(name);
    }
    
    /**
     * sets up the test
     */
    public void setUp() {
        getMessage = "Get this";
        germanMessage = "Ich bin ein Berliner";
        oneArg = "one arg: fooboo";
        twoArg = "two arg: fooboo bubba";
        threeArg = "three arg: fooboo bubba booboo";
        quoteMsg = "You've got mail!";
        html = "<html><body>this is the body</body></html>";
        clazz = DummyClassForMessages.class;
        // Lame instantiation in order to 
        // get JCoverage to shut up
        locale = new Locale("en", "US");
    }

    /*
     * @see junit.framework.TestCase#tearDown()
     */
    public void tearDown() {
        getMessage = null;
        oneArg = null;
        twoArg = null;
        threeArg = null;
        quoteMsg = null;
        clazz = null;
        locale = null;
    }

    /**
     * test that it gets the right unformatted string
     */
    public void testXmlGetString() {
        assertEquals(getMessage, XmlMessages.getInstance().getMessage(clazz, locale,
            "getMessage"));
    }

    /**
     * test that it gets the right unformatted string
     */
    public void testXmlGetStringNoLocale() {
        assertEquals("some value", XmlMessages.getInstance().
            getMessage(clazz, null, "noLocale"));
    }


    /**
     * Test getting all the keys for the bundle
     */
    public void testXmlGetKeys() {
        assertNotNull(XmlMessages.getInstance().getKeys(clazz, locale));
    }
    
    /**
     * test that it gets the right unformatted string
     */
    public void testXmlGetGermanString() {

        String gmessage = XmlMessages.getInstance().getMessage(
            clazz, new java.util.Locale("de", "DE"), "getMessage");
        assertEquals(germanMessage, gmessage);
    }

    /**
     * Test that it formats a one-arg string correctly
     */
    public void testXmlFormatOneArg() {
        assertEquals(oneArg, XmlMessages.getInstance().format(
            clazz, locale, "oneArg", "fooboo"));
    }
    /**
     * Test that it formats a two-arg string correctly
     */
    public void testXmlFormatTwoArg() {
        assertEquals(twoArg, XmlMessages.getInstance().format(
            clazz, locale, "twoArg", "fooboo", "bubba"));
    }
    /**
     * Test that it formats a three-arg string correctly
     */
    public void testXmlFormatThreeArg() {
        assertEquals(threeArg, XmlMessages.getInstance().format(
            clazz, locale, "threeArg", "fooboo", "bubba", "booboo"));
    }
    
    /**
     * Test that it escapes single quotes correctly.
     */
    public void testXmlEscapeQuote() {
        String recieved = XmlMessages.getInstance().format(clazz, locale,
                "quotewitharg", "mail");
        assertEquals(quoteMsg, recieved);
    }

    /**
     * Test unescaping the HTML
     */
    public void testUnescapeHtml() {
        // htmltest
        String recieved = XmlMessages.getInstance().getMessage(clazz, locale,
            "htmltest");
        assertEquals(html, recieved);
    }
    
    /**
     * Make sure we fail if there's no resource bundle
     *
     */
    public void testXmlNoResourceBundle() {
        try {
            XmlMessages.getInstance().format(
                String.class, locale, "bogus", "super-bogus");
            fail("Didn't get expected exception");
        }
        catch (java.util.MissingResourceException e) {
            //expected
        }
    }
}
