/**
 * Copyright (c) 2012 Novell
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
package com.redhat.rhn.common.validator.test;

import com.redhat.rhn.common.validator.HostPortValidator;

import junit.framework.TestCase;

/**
 * Test class for the {@link HostPortValidator}.
 */
public class HostPortValidatorTest extends TestCase {

    public void testIPv4() {
        assertTrue(HostPortValidator.getInstance().isValid("192.168.1.2"));
        assertTrue(HostPortValidator.getInstance().isValid("192.168.1.2:8888"));
        assertTrue(HostPortValidator.getInstance().isValid("192.168.1"));

        assertFalse(HostPortValidator.getInstance().isValid("192.168.1.2:"));
        assertFalse(HostPortValidator.getInstance().isValid("192.168.1.2.3"));
        assertFalse(HostPortValidator.getInstance().isValid("1200.5.4.3"));
        assertFalse(HostPortValidator.getInstance().isValid("192.168.2.1:888888"));
        assertFalse(HostPortValidator.getInstance().isValid("http://192.168.2.1:8888"));
    }

    public void testIPv6() {
        assertTrue(HostPortValidator.getInstance().isValid(
            "2001:0db8:85a3:08d3:1319:8a2e:0370:7344"));
        assertTrue(HostPortValidator.getInstance().isValid(
            "[2001:0db8:85a3:08d3:1319:8a2e:0370:7344]"));
        assertTrue(HostPortValidator.getInstance().isValid(
            "[2001:0db8:85a3:08d3:1319:8a2e:0370:7344]:8888"));
        assertTrue(HostPortValidator.getInstance().isValid("[2607:f0d0:1002:51::4]:8888"));
        assertTrue(HostPortValidator.getInstance().isValid("[::1]"));
        assertTrue(HostPortValidator.getInstance().isValid("[::1]:8888"));

        assertFalse(HostPortValidator.getInstance().isValid(
            "2001:0db8:85a3:08d3:1319:8a2e:0370:7344:8888"));
        assertFalse(HostPortValidator.getInstance().isValid(
            "[2001:0db8:85a3:08d3:1319:8a2e:0370:7344]]:8888"));
        assertFalse(HostPortValidator.getInstance().isValid(
            "[2001:0db8:85a3:08d3:1319:8a2e:0370:7344:8888"));
        assertFalse(HostPortValidator.getInstance().isValid(
            "2001:0db8:85a3:08d3:1319:8a2e:0370:7344]:8888"));
        assertFalse(HostPortValidator.getInstance().isValid("[::1]:"));
        assertFalse(HostPortValidator.getInstance().isValid("[]"));
    }

    public void testHostnames() {
        assertTrue(HostPortValidator.getInstance().isValid("myproxy"));
        assertTrue(HostPortValidator.getInstance().isValid("myproxy:8888"));
        assertTrue(HostPortValidator.getInstance().isValid("proxy.example.com"));
        assertTrue(HostPortValidator.getInstance().isValid("proxy.example.com:8888"));

        assertFalse(HostPortValidator.getInstance().isValid("http://proxy.example.com"));
        assertFalse(HostPortValidator.getInstance().isValid(
            "http://proxy.example.com:8888"));
    }

    public void testHostnameCharset() {
        assertTrue(HostPortValidator.getInstance().isValid("müller"));
        assertTrue(HostPortValidator.getInstance().isValid("pröxy.com"));

        assertFalse(HostPortValidator.getInstance().isValid("pröxy.com;8888"));
        assertFalse(HostPortValidator.getInstance().isValid("pröxy com"));
        assertFalse(HostPortValidator.getInstance().isValid("pro xy:8888"));
        assertFalse(HostPortValidator.getInstance().isValid("p$r%o&x!y="));
    }
}
