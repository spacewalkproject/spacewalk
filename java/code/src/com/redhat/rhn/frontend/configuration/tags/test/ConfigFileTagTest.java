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
import com.redhat.rhn.domain.config.ConfigFileType;
import com.redhat.rhn.frontend.configuration.tags.ConfigFileTag;
import com.redhat.rhn.frontend.configuration.tags.ConfigTagHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockJspWriter;
import com.redhat.rhn.testing.TagTestUtils;

import com.mockobjects.helpers.TagTestHelper;

import java.net.URL;

import javax.servlet.jsp.tagext.Tag;


/**
 * ConfigFileTagTest
 * @version $Rev$
 */
public class ConfigFileTagTest extends RhnBaseTestCase {
    /**
     * Called once per test method.
     * @throws Exception if an error occurs during setup.
     */
    protected void setUp() throws Exception {
        super.setUp();
        ConfigFileTag tag = new ConfigFileTag();
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest(); 
        TagTestHelper tth = TagTestUtils.setupTagTest(tag, 
                                        new URL("http://localhost"),
                                        request);
        tag.setPageContext(tth.getPageContext());        
    }   
    
    /** Test tag output for files
     */
    public void testFile() throws Exception {

        String alt = ConfigFileTag.FILE_ALT_KEY;
        String imgName = ConfigFileTag.FILE_LIST_ICON;
        
        execTest(0, "bar",
                    ConfigFileType.file().getLabel(),
                        false, alt, imgName);
    }
    
    /** Test tag output for files
     */
    public void testDirs() throws Exception {

        String alt = ConfigFileTag.DIR_ALT_KEY;
        String imgName = ConfigFileTag.DIR_LIST_ICON;
        
        execTest(0, "bar",
                    ConfigFileType.dir().getLabel(),
                        false, alt, imgName);
        execTest(0, "bar", "dir", false, alt, imgName);
        execTest(0, "bar", "directory", false, alt, imgName);
        execTest(0, "bar", "folder", false, alt, imgName);
        execTest(-2, "bar", "folder", false, alt, imgName);
        execTest(0, "bar",
                ConfigFileType.dir().getLabel(),
                    true, alt, imgName, 2);        
    }    
    public void testFailure() throws Exception {

        ConfigFileTag tag = new ConfigFileTag();
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest(); 
        TagTestHelper tth = TagTestUtils.setupTagTest(tag, 
                                        new URL("http://localhost"),
                                        request);
        tag.setPageContext(tth.getPageContext());
        tag.setId(String.valueOf(1));
        tag.setPath("FOO");

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
              String altKey, String imgName)  throws Exception {
        execTest(id, name, type, nolink, altKey, imgName, -1);
    }
    public void execTest(int id, String name, 
                           String type, boolean nolink,
                             String altKey, String imgName, 
                                     int revisionId) throws Exception {
        ConfigFileTag tag = new ConfigFileTag();
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest(); 
        TagTestHelper tth = TagTestUtils.setupTagTest(tag, 
                                        new URL("http://localhost"),
                                        request);
        tag.setPageContext(tth.getPageContext());
        if (id >= 0) {
            tag.setId(String.valueOf(id));    
        }
        
        tag.setPath(name);
        tag.setType(type);
        tag.setNolink(String.valueOf(nolink));
        if (revisionId >= 0) {
            tag.setRevisionId(String.valueOf(revisionId));
        }
        
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
            String url = "<a href=\"" + ConfigFileTag.FILE_URL + "?cfid=" + id;
            assertTrue(rout.toString().startsWith(url));
            if (revisionId >= 0) {
                url = "<a href=\"" + ConfigFileTag.FILE_URL + 
                                          "?ccid=" + id + "&crid=" + revisionId;
                assertTrue(rout.toString().startsWith(url));
            }
        }
        else {
            assertFalse(rout.toString().startsWith("<a href"));
        }
        
    }
    
    public void testFunctions() {
        checkFunctions(ConfigFileTag.DIR_HEADER_ICON, 
                                  ConfigFileTag.DIR_ALT_KEY,
                            "dir");
        //also checking case sensititvity
        checkFunctions(ConfigFileTag.DIR_HEADER_ICON, 
                            ConfigFileTag.DIR_ALT_KEY,
                              "dirECtory");
        checkFunctions(ConfigFileTag.DIR_HEADER_ICON, 
                                 ConfigFileTag.DIR_ALT_KEY,
                                  "folder");
        
        checkFunctions(ConfigFileTag.FILE_HEADER_ICON, 
                            ConfigFileTag.FILE_ALT_KEY,
                                 "file");
        
        String url = ConfigFileTag.makeConfigFileRevisionUrl("" + 1, "" + 2);
        assertTrue(url.indexOf("crid=2") > -1);
        assertTrue(url.indexOf("cfid=1") > -1);
        assertTrue(url.startsWith(ConfigFileTag.FILE_URL));
        
        url = ConfigFileTag.makeConfigFileUrl("" + 1);
        assertTrue(url.indexOf("cfid=1") > -1);
        assertTrue(url.startsWith(ConfigFileTag.FILE_URL));
        
        
        url = ConfigFileTag.makeFileCompareUrl("" + 1);
        assertTrue(url.indexOf("cfid=1") > -1);
        assertTrue(url.startsWith(ConfigFileTag.FILE_COMPARE_URL));
   }
    
    private void checkFunctions(String icon, String altKey, String type) {
        assertEquals(altKey, ConfigFileTag.getAltKeyFor(type));
        assertEquals(icon, ConfigFileTag.getHeaderIconFor(type));
    }
}
