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
package com.redhat.rhn.domain.server;

import com.redhat.rhn.domain.user.User;

import java.util.Date;

/**
 * ServerLock - Class representation of the table rhnServerLock.
 * @version $Rev: 1 $
 */
public class ServerLock {

    private Long id;
    private Server server;
    private User locker;
    private String reason;
    private Date created;

    /** Default constructor */
    public ServerLock() {

    }

    /**
     * @param lockerIn User locking the server
     * @param s Server being locked
     * @param reasonIn reason the server is being locked
     */
    public ServerLock(User lockerIn, Server s, String reasonIn) {
        this.locker = lockerIn;
        this.server = s;
        this.reason = reasonIn;
    }

    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
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
     * Getter for locker
     * @return User to get
    */
    public User getLocker() {
        return this.locker;
    }

    /**
     * Setter for locker
     * @param lockerIn to set
    */
    public void setLocker(User lockerIn) {
        this.locker = lockerIn;
    }

    /**
     * Getter for reason
     * @return String to get
    */
    public String getReason() {
        return this.reason;
    }

    /**
     * Setter for reason
     * @param reasonIn to set
    */
    public void setReason(String reasonIn) {
        this.reason = reasonIn;
    }

    /**
     * Getter for created
     * @return Date to get
    */
    public Date getCreated() {
        return this.created;
    }

    /**
     * Setter for created
     * @param createdIn to set
    */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

}
