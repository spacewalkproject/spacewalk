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
package com.redhat.rhn.domain.user;

import com.redhat.rhn.domain.server.Server;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;

/**
 * UserServerPreferenceId
 * @version $Rev$
 */
public class UserServerPreferenceId implements Serializable {
    
    public static final String RECEIVE_NOTIFICATIONS = "receive_notifications";
    public static final String INCLUDE_IN_DAILY_SUMMARY = "include_in_daily_summary";
    
    private User user;
    private Server server;
    private String name;
    
    /**
     * Create a new UserServerPreferenceId
     * @param userIn user corresponding to the preference
     * @param serverIn server corresponding to the preference
     * @param nameIn property name corresponding to the preference
     */
    public UserServerPreferenceId(User userIn, Server serverIn, String nameIn) {
        this.user = userIn;
        this.server = serverIn;
        this.name = nameIn;
    }
    /**
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }
    /**
     * @param nameIn The name to set.
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }
    /**
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }
    /**
     * @param serverIn The server to set.
     */
    public void setServer(Server serverIn) {
        this.server = serverIn;
    }
    /**
     * @return Returns the user.
     */
    public User getUser() {
        return user;
    }
    /**
     * @param userIn The user to set.
     */
    public void setUser(User userIn) {
        this.user = userIn;
    }
    
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (other == null || !(other instanceof UserServerPreferenceId)) {
            return false;
        }
        UserServerPreferenceId castOther = (UserServerPreferenceId) other;

        return new EqualsBuilder().append(server, castOther.getServer())
                                  .append(user, castOther.getUser())
                                  .append(name, castOther.getName())
                                  .isEquals();
    }
    
    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(server)
                                    .append(user)
                                    .append(name)
                                    .hashCode();
    }

    
}
