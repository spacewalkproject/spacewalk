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
    private String type;


    /**
     *
     * @param checksumIn checksum info
     * @param openChecksumIn open checksum info
     * @param timestampIn timestamp
     */
    public RepomdIndexData(String checksumIn, String openChecksumIn, Date timestampIn) {
        this.checksum = checksumIn;
        this.openChecksum = openChecksumIn;
        this.timestamp = timestampIn;
    }

    /**
     *
     * @return checksum type
     */
    public String getType() {
        return type;
    }

    /**
     * This is specifically for type value in repomd.xml
     * @param typeIn checksum type
     */
    public void setType(String typeIn) {
        this.type = typeIn;
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
     * @param checksumIn The checksum to set.
     */
    public void setChecksum(String checksumIn) {
        this.checksum = checksumIn;
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
     * @param openChecksumIn The open checksum to set.
     */
    public void setOpenChecksum(String openChecksumIn) {
        this.openChecksum = openChecksumIn;
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
     * @param timestampIn The timestamp to set.
     */
    public void setTimestamp(Date timestampIn) {
        this.timestamp = timestampIn;
    }
}
