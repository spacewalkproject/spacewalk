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
package com.redhat.rhn.frontend.configuration.tags.test;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.frontend.configuration.tags.ConfigChannelTag;
import com.redhat.rhn.frontend.configuration.tags.ConfigTagHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockJspWriter;
import com.redhat.rhn.testing.TagTestUtils;

import com.mockobjects.helpers.TagTestHelper;

import java.net.URL;

import javax.servlet.jsp.tagext.Tag;

/**
 * ConfigChannelTagTest
 * @version $Rev$
 */
public class ConfigChannelTagTest extends RhnBaseTestCase {
    /**
     * Called once per test method.
     * @throws Exception if an error occurs during setup.
     */
    protected void setUp() throws Exception {
        super.setUp();
        ConfigChannelTag tag = new ConfigChannelTag();
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest();
        TagTestHelper tth = TagTestUtils.setupTagTest(tag,
                                        new URL("http://localhost"),
                                        request);
        tag.setPageContext(tth.getPageContext());
    }

    /** Test tag output for central
     */
    public void testCentral() throws Exception {

        String alt = ConfigChannelTag.CENTRAL_ALT_KEY;
        String imgName = ConfigChannelTag.CENTRAL_LIST_ICON;

        execTest(0, "bar",
                    ConfigChannelType.global().getLabel(),
                        false, alt, imgName);

        execTest(1, "bar1", "central", false, alt, imgName);

        execTest(2, "bar2", "global", false, alt, imgName);
        //also checking case sensititvity
        execTest(2, "bar2", "gloBal", false, alt, imgName);
        execTest(-2, "bar2", "gloBal", false, alt, imgName);
        execTest(2, "bar2", "global", true, alt, imgName);
    }

    /** Test tag output for central
     */
    public void testLocal() throws Exception {

        String alt = ConfigChannelTag.LOCAL_ALT_KEY;
        String imgName = ConfigChannelTag.LOCAL_LIST_ICON;
        execTest(0, "bar",
                    ConfigChannelType.local().getLabel(),
                        false, alt, imgName);
        execTest(1, "bar1", "local", false, alt, imgName);
    }

    public void testSandbox() throws Exception {

        String alt = ConfigChannelTag.SANDBOX_ALT_KEY;
        String imgName = ConfigChannelTag.SANDBOX_LIST_ICON;
        execTest(0, "bar",
                    ConfigChannelType.sandbox().getLabel(),
                        false, alt, imgName);
        execTest(1, "bar1", "sandbox", false, alt, imgName);
    }

    public void testFailure() throws Exception {

        ConfigChannelTag tag = new ConfigChannelTag();
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest();
        TagTestHelper tth = TagTestUtils.setupTagTest(tag,
                                        new URL("http://localhost"),
                                        request);
        tag.setPageContext(tth.getPageContext());
        tag.setId(String.valueOf(1));
        tag.setName("FOO");

        String type = "FAILURE";
        tag.setType(type);

        // ok let's test the tag
        tth.assertDoStartTag(Tag.SKIP_BODY);
        tth.assertDoEndTag(Tag.SKIP_BODY);
        RhnMockJspWriter rout = (RhnMockJspWriter) tth.getPageContext().getOut();
        assertTrue(rout.toString().
                indexOf(ConfigTagHelper.CONFIG_ERROR_ALT_TEXT) > -1);
        assertTrue(rout.toString().
                indexOf(ConfigTagHelper.CONFIG_ERROR_IMG) > -1);
    }

    public void execTest(int id, String name,
                           String type, boolean nolink,
                             String altKey, String imgName) throws Exception {
        ConfigChannelTag tag = new ConfigChannelTag();
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest();
        TagTestHelper tth = TagTestUtils.setupTagTest(tag,
                                        new URL("http://localhost"),
                                        request);
        tag.setPageContext(tth.getPageContext());
        if (id >= 0) {
            tag.setId(String.valueOf(id));
        }

        tag.setName(name);
        tag.setType(type);
        tag.setNolink(String.valueOf(nolink));

        // ok let's test the tag
        tth.assertDoStartTag(Tag.SKIP_BODY);
        tth.assertDoEndTag(Tag.SKIP_BODY);

        RhnMockJspWriter rout = (RhnMockJspWriter) tth.getPageContext().getOut();

        assertTrue(rout.toString().indexOf(name) > -1);
        assertFalse(rout.toString().indexOf("alt = \"\"") > -1);

        LocalizationService service = LocalizationService.getInstance();
        String alt = service.getMessage(altKey);
        assertTrue(rout.toString().indexOf(alt) > -1);
        assertTrue(rout.toString().indexOf(imgName) > -1);
        if (!nolink && id >= 0) {
            String url = "<a href=\"" + ConfigChannelTag.CHANNEL_URL +
                                                            "?ccid=" + id;
            assertTrue(rout.toString().startsWith(url));
        }
        else {
            assertFalse(rout.toString().startsWith("<a href"));
        }
    }

    public void testFunctions() {
        checkFunctions(ConfigChannelTag.CENTRAL_HEADER_ICON,
                            ConfigChannelTag.CENTRAL_ALT_KEY,
                            "global");
        //also checking case sensititvity
        checkFunctions(ConfigChannelTag.CENTRAL_HEADER_ICON,
                        ConfigChannelTag.CENTRAL_ALT_KEY,
                            "cenTral");

        checkFunctions(ConfigChannelTag.CENTRAL_HEADER_ICON,
                        ConfigChannelTag.CENTRAL_ALT_KEY,
                   ConfigChannelType.global().getLabel());



        checkFunctions(ConfigChannelTag.LOCAL_HEADER_ICON,
                        ConfigChannelTag.LOCAL_ALT_KEY,
                            "local");


        checkFunctions(ConfigChannelTag.LOCAL_HEADER_ICON,
                ConfigChannelTag.LOCAL_ALT_KEY,
           ConfigChannelType.local().getLabel());


        checkFunctions(ConfigChannelTag.SANDBOX_HEADER_ICON,
                        ConfigChannelTag.SANDBOX_ALT_KEY,
                            "sandbox");


        checkFunctions(ConfigChannelTag.SANDBOX_HEADER_ICON,
                ConfigChannelTag.SANDBOX_ALT_KEY,
           ConfigChannelType.sandbox().getLabel());

        String url = ConfigChannelTag.makeConfigChannelUrl("" + 1);
        assertTrue(url.indexOf("ccid=1") > -1);
        assertTrue(url.startsWith(ConfigChannelTag.CHANNEL_URL));
    }

    private void checkFunctions(String icon, String altKey, String type) {
        assertEquals(altKey, ConfigChannelTag.getAltKeyFor(type));
        assertEquals(icon, ConfigChannelTag.getHeaderIconFor(type));
    }
}
