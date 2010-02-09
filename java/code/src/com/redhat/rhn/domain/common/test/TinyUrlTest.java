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
package com.redhat.rhn.domain.common.test;

import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.TinyUrl;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;

/**
 * TinyUrlTest
 * @version $Rev$
 */
public class TinyUrlTest extends RhnBaseTestCase {

    public void testCreate() throws Exception {
        TinyUrl url = CommonFactory.createTinyUrl(
                "/rhn/kickstart/ks-rhel-i386-as-4-u2", new Date());
        assertNotNull(url);
        CommonFactory.saveTinyUrl(url);
        url = CommonFactory.lookupTinyUrl(url.getToken());
        assertNotNull(url.getToken());
    }

    public void testComputeUrl() throws Exception {
        TinyUrl url = CommonFactory.createTinyUrl(
                "/rhn/kickstart/ks-rhel-i386-as-4-u2", new Date());
        String path = url.computeTinyUrl("xmlrpc.rhn.webdev.redhat.com");
        assertNotNull(path);
        String expected = "http://xmlrpc.rhn.webdev.redhat.com/ty/" + url.getToken();
        assertEquals(expected, path);
    }
    
    public void testComputeTinyPath() {
        TinyUrl url = CommonFactory.createTinyUrl(
                "/rhn/kickstart/ks-rhel-i386-as-4-u2", new Date());
        String expected = "/ty/" + url.getToken();
        assertEquals(expected, url.computeTinyPath());
    }
    
    public void testDateMath() {
        TimeZone defaulttz = TimeZone.getDefault();
        Calendar pcal = Calendar.getInstance();
        TimeZone.setDefault(TimeZone.getTimeZone("America/New_York"));
        Date zero = new Date(0);
        pcal.setTime(zero);
        pcal.add(Calendar.HOUR, 4);
        
        TinyUrl url = CommonFactory.createTinyUrl(
                "/rhn/kickstart/ks-rhel-i386-as-4-u2", pcal.getTime());

        assertEquals("Thu Jan 01 03:00:00 EST 1970", url.getExpires().toString());
        TimeZone.setDefault(defaulttz);
    }
}
