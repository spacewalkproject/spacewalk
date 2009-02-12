/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.taskomatic.task.repomd;

import java.util.Date;
/**
 * 
 * @version $Rev $
 *
 */
public class RepomdIndexData {
    private String checksum;
    private String openChecksum;
    private Date timestamp;

    /**
     * 
     * @param checksum checksum info
     * @param openChecksum open checksum info
     * @param timestamp timestamp
     */
    public RepomdIndexData(String checksum, String openChecksum, Date timestamp) {
        this.checksum = checksum;
        this.openChecksum = openChecksum;
        this.timestamp = timestamp;
    }
    /**
     * 
     * @return checksum info
     */
    public String getChecksum() {
        return checksum;
    }
    /**
     * 
     * @param checksum The checksum to set.
     */
    public void setChecksum(String checksum) {
        this.checksum = checksum;
    }
    /**
     * 
     * @return The open checksum
     */
    public String getOpenChecksum() {
        return openChecksum;
    }
    /**
     * 
     * @param openChecksum The open checksum to set.
     */
    public void setOpenChecksum(String openChecksum) {
        this.openChecksum = openChecksum;
    }
    /**
     * 
     * @return Returns timestamp
     */
    public Date getTimestamp() {
        return timestamp;
    }
    /**
     * 
     * @param timestamp The timestamp to set.
    */
    public void setTimestamp(Date timestamp) {
        this.timestamp = timestamp;
    }
}
