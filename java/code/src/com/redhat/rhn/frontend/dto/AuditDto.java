
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
