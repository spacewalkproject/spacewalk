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
package com.redhat.rhn.common.validator;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Input validation for host[:port], where the host part can be either an IP address
 * (IPv4 or IPv6) or a hostname.
 */
public class HostPortValidator {

    // Singleton instance
    private static HostPortValidator instance;

    // Pattern to match IPv6 address in bracket notation
    private static final Pattern IPV6_BRACKETS = Pattern.compile("^\\[(.*)\\](:(\\d*))?$");

    // Allow letters (of all languages), numbers, '.' and '-'
    private static final Pattern HOSTNAME = Pattern.compile("^[\\p{L}\\p{N}.-]*$");

    // Private constructor
    private HostPortValidator() {
    }

    /**
     * Return the singleton instance of {@link HostPortValidator}.
     * @return {@link HostPortValidator} instance
     */
    public static HostPortValidator getInstance() {
        if (instance == null) {
            instance = new HostPortValidator();
        }
        return instance;
    }

    /**
     * Return true if the given string is a valid host[:port] representation.
     * @param hostPort the string with host[:port]
     * @return true if hostPort represents a valid host and port, else false.
     */
    public boolean isValid(String hostPort) {
        if (hostPort == null || hostPort.isEmpty()) {
            return false;
        }
        String host;
        String port;

        if (hostPort.startsWith("[")) {
          // Parse an IPv6 address in bracket notation
          Matcher matcher = IPV6_BRACKETS.matcher(hostPort);
          if (!matcher.matches()) {
              return false;
          }
          host = matcher.group(1);
          port = matcher.group(3);
        }
        else {
          int colonIndex = hostPort.indexOf(':');
          if (colonIndex != -1 && colonIndex == hostPort.lastIndexOf(':')) {
            // Split into host:port
            host = hostPort.substring(0, colonIndex);
            port = hostPort.substring(colonIndex + 1);
          }
          else {
            host = hostPort;
            port = null;
          }
        }

        // Validate host and port separately
        boolean isValidHost = true;
        // Validate IP addresses externally (v4 and v6)
        if (host.replaceAll("[\\d\\.]", "").isEmpty() || host.contains(":")) {
            isValidHost = isValidIP(host);
        } else {
            // Validate hostname charset
            Matcher matcher = HOSTNAME.matcher(host);
            isValidHost = matcher.matches() ? isValidHost : false;
        }
        boolean isValidPort = true;
        if (port != null) {
            isValidPort = isValidPort(port);
        }

        return isValidHost && isValidPort;
    }

    /**
     * Validate IP address format for a given string.
     * @param ipString
     * @return true if the given string is a valid IP, else false.
     */
    private boolean isValidIP(String ipString) {
        boolean ret = false;
        if (ipString != null && !ipString.isEmpty()) {
            try {
                InetAddress.getByName(ipString);
                ret = true;
            }
            catch (UnknownHostException e) {
                // Stay silent
            }
        }
        return ret;
    }

    /**
     * Parse a port number from a given string and validate it.
     * @param portString
     * @return true if the given string is a valid port, else false.
     */
    private boolean isValidPort(String portString) {
        boolean ret = false;
        if (portString != null && !portString.isEmpty()) {
            try {
                int port = Integer.parseInt(portString);
                ret = port >= 0 && port < 65535;
            }
            catch (NumberFormatException e) {
                // Stay silent
            }
        }
        return ret;
    }
}
