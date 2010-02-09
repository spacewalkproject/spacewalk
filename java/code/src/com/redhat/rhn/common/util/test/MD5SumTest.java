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

import com.redhat.rhn.common.util.MD5Sum;
import com.redhat.rhn.testing.TestUtils;

import java.io.File;
import java.util.Random;

import junit.framework.TestCase;


/**
 * @author mmccune
 *
 */
public class MD5SumTest extends TestCase {

    public void testMD5Sum() throws Exception {
        File testFile = new File(TestUtils.findTestData("test.file").getFile());
        String sum = MD5Sum.getFileMD5Sum(testFile);
        assertEquals("ab0aa62f30d67085cd07ea9004a1437f", sum);
    }
    
    /**
     * Note that this test creates a large 100MB file in /tmp
     * and then does an md5sum on the file.
     * 
     * With a previous implementation of MD5Sum.getFileMD5Sum() this would
     * cause an OOME with a max-heap size in junit of 256m.  This is configured in:
     * spacewalk/buildconf/build-utils.xml:
     * 
     *       <junit forkmode="once" fork="yes" printsummary="off" showoutput="yes"
     *        haltonfailure="${halt-tests-on-failure}" 
     *        failureproperty="junit_test_failure" maxmemory="256m">
     *
     * The new implementation uses less memory and thus passes the test below when ran
     * from Junit CLI.
     * 
     * @throws Exception
     */
    public void testOOMEMD5Sum() throws Exception {
        File large = new File("/tmp/large-file.dat");
        // Create a large 100mb file
        large.createNewFile();
        writeRandomLargeBytesToFile(large);
        String sum = MD5Sum.getFileMD5Sum(large);
        assertNotNull(sum);
        large.delete();
    }
    
    private static void writeRandomLargeBytesToFile(File f) {
        byte[] ba = new byte[101326592];
        Random r = new Random();
        r.nextBytes(ba);
        TestUtils.writeByteArrayToFile(f, ba);
    }
}
