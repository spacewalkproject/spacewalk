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
package com.redhat.rhn.frontend.dto;

import java.util.Date;
import java.util.LinkedHashMap;

/**
 * AuditDto
 * @version $Rev$
 */
public class AuditDto extends BaseDto {
    private Long id;
    private int serial;
    private Date time;
    private int milli;
    private String node;

    private LinkedHashMap<String, String> kvmap;

    private String type;

    /**
     * Constructor
     * @param serialIn Audit serial number
     * @param timeIn Audit time-of-event
     * @param milliIn Audit millisecond part of timeIn
     * @param nodeIn Audit generating node
     * @param kvmapIn HashMap of audit data
     */
    public AuditDto(int serialIn, Date timeIn, int milliIn, String nodeIn,
                LinkedHashMap<String, String> kvmapIn) {
        this.id = new Long((long)serialIn);
        this.serial = serialIn;
        this.time = timeIn;
        this.milli = milliIn;
        this.node = nodeIn;

        this.kvmap = new LinkedHashMap<String, String>(kvmapIn);

        this.type = kvmap.remove("type");
    }

    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * @return Returns the serial.
     */
    public int getSerial() {
        return serial;
    }

    /**
     * @return Returns the time-of-event.
     */
    public Date getTime() {
        return time;
    }

    /**
     * @return Returns the millisecond part of the event time.
     */
    public int getMilli() {
        return milli;
    }

    /**
     * @return Returns the node.
     */
    public String getNode() {
        return node;
    }

    /**
     * @return Returns the key-value audit data.
     */
    public LinkedHashMap<String, String> getKvmap() {
        return kvmap;
    }

    /**
     * @return Returns the audit type.
     */
    public String getType() {
        return type;
    }
}

// vim: ts=4:expandtab
