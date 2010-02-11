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
package com.redhat.rhn.common.util.test;

import com.redhat.rhn.common.util.FileUtils;
import com.redhat.rhn.testing.TestUtils;

import java.io.File;

import junit.framework.TestCase;


/**
 * @author mmccune
 */
public class FileUtilsTest extends TestCase {
    
    public void testReadWrite() throws Exception {
        String path = "/tmp/" + 
            System.currentTimeMillis() + 
            TestUtils.randomString() + ".cfg";
        // the BufferedWriter will automaticall append a 
        // newline to the end of the file so our test should 
        // just include one.
        String contents = "this is a test\n";
        FileUtils.writeStringToFile(contents, path);
        String reread = FileUtils.readStringFromFile(path);
        assertEquals(contents, reread);
    }

    public void testGetBytesFromFile() throws Exception {
        
        File testFile = new File(TestUtils.findTestData("test.file").getFile());
        byte[] out = FileUtils.readByteArrayFromFile(testFile, 25, 30);
        String received = new String(out);
        String expect = "DEFGH";
        assertEquals(expect, received);
    }
}
