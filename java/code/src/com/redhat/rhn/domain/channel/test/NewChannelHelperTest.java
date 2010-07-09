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
package com.redhat.rhn.domain.channel.test;

import com.redhat.rhn.domain.channel.NewChannelHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;


/**
 * ChannelArchTest
 * @version $Rev$
 */
public class NewChannelHelperTest extends RhnBaseTestCase {


    public void testVerifyName() throws Exception {
       String name = "Redhat-test-channel";
       assertFalse(NewChannelHelper.verifyName(name));
       name = "rhn-test";
       assertFalse(NewChannelHelper.verifyName(name));
       name = "test";
       assertFalse(NewChannelHelper.verifyName(name));
       name = "test-{channel}";
       assertFalse(NewChannelHelper.verifyName(name));
       name = "test-channel";
       assertTrue(NewChannelHelper.verifyName(name));

    }

    public void testVerifyLabel() throws Exception {
        String label = "test-channel";
        assertTrue(NewChannelHelper.verifyLabel(label));
        label = "redhat-channel";
        assertFalse(NewChannelHelper.verifyLabel(label));
        label = "rhn-channel";
        assertFalse(NewChannelHelper.verifyLabel(label));
        label = "test";
        assertFalse(NewChannelHelper.verifyLabel(label));
        label = "test-{channel}";
        assertFalse(NewChannelHelper.verifyLabel(label));
    }

    public void testVerifyGpgFingerprint() throws Exception {
        String fp = "CA20 8686 2BD6 9DFC 65F6 ECC4 2191 80CD DB42 A60E";
        assertTrue(NewChannelHelper.verifyGpgFingerprint(fp));
        fp = "A20 8686 2BD6 9DFC 65F6 ECC4 2191 80CD DB42 A60E";
        assertFalse(NewChannelHelper.verifyGpgFingerprint(fp));
        fp = "8686 2BD6 9DFC 65F6 ECC4 2191 80CD DB42 A60E";
        assertFalse(NewChannelHelper.verifyGpgFingerprint(fp));
        fp = "CA2] 8686 2BD6 9DFC 65F6 ECC4 2191 80CD DB42 A60E";
        assertFalse(NewChannelHelper.verifyGpgFingerprint(fp));
    }

    public void testVerifyGpgId() throws Exception {
        String id = "DB42A60E";
        assertTrue(NewChannelHelper.verifyGpgId(id));
        id = "DB42";
        assertFalse(NewChannelHelper.verifyGpgId(id));
        id = "DB42A50]";
        assertFalse(NewChannelHelper.verifyGpgId(id));

    }

    public void testVerifyGpgUrl() throws Exception {
        String url = "http://test/filename.txt";
        assertTrue(NewChannelHelper.verifyGpgUrl(url));
        url = "https://test/filename.txt";
        assertTrue(NewChannelHelper.verifyGpgUrl(url));
        url = "file://test/filename.txt";
        assertTrue(NewChannelHelper.verifyGpgUrl(url));
        url = "/test/filename.txt";
        assertFalse(NewChannelHelper.verifyGpgUrl(url));
    }

}
