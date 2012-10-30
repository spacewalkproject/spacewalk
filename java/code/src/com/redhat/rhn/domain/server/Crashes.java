/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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

import com.redhat.rhn.domain.BaseDomainHelper;

import java.util.Date;

/**
 * Represents the number of crashes on a particular server.
 * @version $Rev$
 */
public class Crashes extends BaseDomainHelper {

    private Long id;
    private Server server;
    private Date created;
    private long crashCount;

    /**
     * Represents application crash information.
     */
    public Crashes() {
        super();
    }

    /**
     * Returns the database id of the crashes object.
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * Sets the database id of the crashes object.
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        id = idIn;
    }

    /**
     * Returns the date of the last update.
     * @return the date of the last update.
     */
    public Date getCreated() {
        return created;
    }

    /**
     * Sets the date of the last update.
     * @param lastmod Last modification date.
     */
    public void setCreated(Date lastmod) {
        created = lastmod;
    }

    /**
     * The parent server.
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }

    /**
     * Sets the parent server.
     * @param serverIn The server to set.
     */
    public void setServer(Server serverIn) {
        server = serverIn;
    }

    /**
     * Returns the total number of application crashes.
     * @return the total number of application crashes.
     */
    public long getCrashCount() {
        return crashCount;
    }

    /**
     * Sets the total number of application crashes.
     * @param count The total number of crashes.
     */
    public void setCrashCount(long count) {
        crashCount = count;
    }
}
