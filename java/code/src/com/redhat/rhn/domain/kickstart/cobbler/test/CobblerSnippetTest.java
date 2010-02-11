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
package com.redhat.rhn.domain.kickstart.cobbler.test;

import com.redhat.rhn.common.util.FileUtils;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.kickstart.cobbler.CobblerSnippet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import java.io.File;


/**
 * CobblerSnippetTest
 * @version $Rev$
 */
public class CobblerSnippetTest extends BaseTestCaseWithUser {

    public void testReadOnly() throws Exception {
       String contents = TestUtils.randomString();
       String path = CobblerSnippet.getCobblerSnippetsDir() +
                                   "/" + TestUtils.randomString();
       FileUtils.writeStringToFile(contents, path);
       
       CobblerSnippet snip = CobblerSnippet.loadReadOnly(new File(path));
       assertEquals(new File(path), snip.getPath());
       assertEquals(contents, snip.getContents());
       assertFalse(snip.isEditable());
       try {
           snip.writeContents(contents);
           fail("The write operation succeded");
       }
       catch (ValidatorException ve) {
           // thankfully it failed...
       }
       
       try {
           snip.delete();
           fail("The delete operation succeded." +
                               " Shouldn't delete read only");
       }
       catch (ValidatorException ve) {
           // thankfully it failed...
       }       
   }
    
    public void testEditable() throws Exception {
        String contents = TestUtils.randomString();
        String name = TestUtils.randomString();
        CobblerSnippet snip = CobblerSnippet.createOrUpdate(true, name,
                                contents, user.getOrg());
        assertTrue(snip.getPath().exists());
        assertEquals(contents, snip.getContents());
        assertTrue(snip.isEditable());
        contents += "Updated";
        try {
            CobblerSnippet.createOrUpdate(true, name,
                    contents, user.getOrg());
            fail("No error on a create for a already existing file..");
        }
        catch (ValidatorException ve) {
            // cool this case must fail..
        }

        snip = CobblerSnippet.createOrUpdate(false, name,
                contents, user.getOrg());
        assertEquals(contents, snip.getContents());
        
        contents = contents + "Ugh";
        snip.writeContents(contents);
        assertEquals(contents, snip.getContents());
        
        assertEquals(contents, 
                FileUtils.readStringFromFile(snip.getDisplayPath()));
        snip.delete();
        assertFalse(snip.getPath().exists());
    }
    
    public void testIllegalCreates() throws Exception {
        String contents = TestUtils.randomString();
        String name = TestUtils.randomString() + "/HoHO";
        try {
            CobblerSnippet.createOrUpdate(true, name,
                    contents, user.getOrg());
            fail("Create should not happen for the name has a slash in it:(");
        }
        catch (ValidatorException ve) {
            //nice job recognizing the error..
        }
        
        name = TestUtils.randomString();
        CobblerSnippet snip = CobblerSnippet.createOrUpdate(true, name,
                        contents, user.getOrg());
        snip  = CobblerSnippet.loadEditable(name, user.getOrg());
        assertNotNull(snip);
        assertTrue(snip.getPath().exists());
        assertEquals(contents, snip.getContents());
        assertTrue(snip.isEditable());
    }

    /**
     * Useful method to generate and 
     * return a quick read only snippet..
     * @return read only snippet
     */
    public static CobblerSnippet readOnly() {
        String contents = TestUtils.randomString();
        String path = CobblerSnippet.getCobblerSnippetsDir() +
                                    "/" + TestUtils.randomString();
        FileUtils.writeStringToFile(contents, path);
        
        CobblerSnippet snip = CobblerSnippet.loadReadOnly(new File(path));
        assertEquals(new File(path), snip.getPath());
        assertEquals(contents, snip.getContents());
        assertFalse(snip.isEditable());
        return snip;        
    }
    
    /**
     * Useful method to generate and 
     * return a quick editable snippet..
     * @param user user object needed for org information
     * @return the editable snippet
     */
    public static CobblerSnippet editable(User user) {
        String contents = TestUtils.randomString();
        String name = TestUtils.randomString();
        CobblerSnippet snip = CobblerSnippet.createOrUpdate(true, name,
                                contents, user.getOrg());
        assertTrue(snip.getPath().exists());
        assertEquals(contents, snip.getContents());
        assertTrue(snip.isEditable());
        return snip;
    }    
}
