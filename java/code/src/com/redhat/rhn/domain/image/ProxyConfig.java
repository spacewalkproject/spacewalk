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

package com.redhat.rhn.domain.image;

/**
 * Simple class representing a proxy configuration.
 */
public class ProxyConfig {
    private String server;
    private String user;
    private String pass;

    /**
     * Constructor for creating a proxy configuration.
     * @param serverIn server
     * @param userIn user
     * @param passIn password
     */
    public ProxyConfig(String serverIn, String userIn, String passIn) {
        this.setServer(serverIn);
        this.setUser(userIn);
        this.setPass(passIn);
    }

    /**
     * Return the server.
     * @return server
     */
    public String getServer() {
        return server;
    }

    /**
     * Set the server.
     * @param serverIn server
     */
    public void setServer(String serverIn) {
        this.server = serverIn;
    }

    /**
     * Return the user.
     * @return user
     */
    public String getUser() {
        return user;
    }

    /**
     * Set the user.
     * @param userIn user
     */
    public void setUser(String userIn) {
        this.user = userIn;
    }

    /**
     * Return the password.
     * @return password
     */
    public String getPass() {
        return pass;
    }

    /**
     * Set the password.
     * @param passIn password
     */
    public void setPass(String passIn) {
        this.pass = passIn;
    }
}
