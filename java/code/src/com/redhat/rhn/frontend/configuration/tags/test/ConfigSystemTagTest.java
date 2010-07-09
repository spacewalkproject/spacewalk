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
import com.redhat.rhn.frontend.configuration.tags.ConfigSystemTag;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockJspWriter;
import com.redhat.rhn.testing.TagTestUtils;

import com.mockobjects.helpers.TagTestHelper;

import java.net.URL;

import javax.servlet.jsp.tagext.Tag;

/**
 * ConfigSystemTagTest
 * @version $Rev$
 */
public class ConfigSystemTagTest extends RhnBaseTestCase {
    /**
     * Called once per test method.
     * @throws Exception if an error occurs during setup.
     */
    protected void setUp() throws Exception {
        super.setUp();
        ConfigSystemTag tag = new ConfigSystemTag();
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest();
        TagTestHelper tth = TagTestUtils.setupTagTest(tag,
                                        new URL("http://localhost"),
                                        request);
        tag.setPageContext(tth.getPageContext());
    }

    /** Test tag output for files
     */
    public void testSystem() throws Exception {

        String alt = ConfigSystemTag.SYSTEM_ALT_KEY;
        String imgName = ConfigSystemTag.SYSTEM_LIST_ICON;

        execTest(0, "bar", false, alt, imgName);
    }

    public void execTest(int id, String name, boolean nolink,
              String altKey, String imgName)  throws Exception {
        ConfigSystemTag tag = new ConfigSystemTag();
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest();
        TagTestHelper tth = TagTestUtils.setupTagTest(tag,
                                        new URL("http://localhost"),
                                        request);
        tag.setPageContext(tth.getPageContext());
        if (id >= 0) {
            tag.setId(String.valueOf(id));
        }

        tag.setName(name);
        tag.setNolink(String.valueOf(nolink));

        // ok let's test the tag
        tth.assertDoStartTag(Tag.SKIP_BODY);
        tth.assertDoEndTag(Tag.SKIP_BODY);

        RhnMockJspWriter rout = (RhnMockJspWriter) tth.getPageContext().getOut();

        assertTrue(rout.toString().indexOf(name) > -1);
        assertFalse(rout.toString().indexOf("alt =\"\"") > -1);
        LocalizationService service = LocalizationService.getInstance();
        String alt = service.getMessage(altKey);
        assertTrue(rout.toString().indexOf(alt) > -1);
        assertTrue(rout.toString().indexOf(imgName) > -1);
        if (!nolink && id >= 0) {
            String url = "<a href=\"" + ConfigSystemTag.SYSTEM_URL + "?sid=" + id;
            assertTrue(rout.toString().startsWith(url));
        }
        else {
            assertFalse(rout.toString().startsWith("<a href"));
        }

    }

    public void testFunctions() {
        checkFunctions(ConfigSystemTag.SYSTEM_HEADER_ICON,
                                  ConfigSystemTag.SYSTEM_ALT_KEY,
                            "system");
        //also checking case sensititvity
        checkFunctions(ConfigSystemTag.SYSTEM_HEADER_ICON,
                            ConfigSystemTag.SYSTEM_ALT_KEY,
                              "sYsTem");

        String url = ConfigSystemTag.makeConfigSystemUrl("" + 1);
        assertTrue(url.indexOf("sid=1") > -1);
        assertTrue(url.startsWith(ConfigSystemTag.SYSTEM_URL));
   }

    private void checkFunctions(String icon, String altKey, String type) {
        assertEquals(altKey, ConfigSystemTag.getAltKeyFor());
        assertEquals(icon, ConfigSystemTag.getHeaderIconFor());
    }
}
