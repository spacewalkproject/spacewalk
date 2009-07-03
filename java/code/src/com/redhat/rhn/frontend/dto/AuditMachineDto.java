
package com.redhat.rhn.frontend.dto;

import java.util.Date;

/**
 * AuditMachineDto
 * @version $Rev$
 */
public class AuditMachineDto extends BaseDto implements Comparable<AuditMachineDto> {
    private Long id;
    private String machineName;
    private Date lastReview, firstUnreviewed;

    /**
     * Constructor
     * @param nameIn The machine name
     * @param lastReviewIn The date of the last review
     * @param firstUnreviewedIn The date of the first unreviewed log section
     */
    public AuditMachineDto(String nameIn, Date lastReviewIn,
            Date firstUnreviewedIn) {
        this.id = 0L;
        this.machineName = nameIn;
        this.lastReview = lastReviewIn;
        this.firstUnreviewed = firstUnreviewedIn;
    }

    /**
     * @return Returns whether or not this machine is in need of review.
     */
    public boolean getNeedsReview() {
        long seconds, days;
        Date now;

        if (firstUnreviewed == null) {
            // no unreviewed logs
            return false;
        }

        now = new Date();
        seconds = (now.getTime() - firstUnreviewed.getTime()) / 1000;
        days = seconds / (60 * 60 * 24);

        return days > 7;
    }

    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * @return Returns the machine name.
     */
    public String getName() {
        return machineName;
    }

    /**
     * @return Returns the date of the last review.
     */
    public Date getLastReview() {
        return lastReview;
    }

    /**
     * @return Returns the date of the first unreviewed section.
     */
    public Date getFirstUnreviewed() {
        return firstUnreviewed;
    }

    /** {@inheritDoc} */
    public int compareTo(AuditMachineDto other) {
        return getName().compareTo(other.getName());
    }
}

// vim: ts=4:expandtab
