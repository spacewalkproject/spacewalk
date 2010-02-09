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

/**
 * AuditReviewDto
 * @version $Rev$
 */
public class AuditReviewDto extends BaseDto implements Comparable<AuditReviewDto> {
    private Long id;
    private String name;
    private Date start;
    private Date end;
    private String reviewedBy;
    private Date reviewedOn;

    /**
     * Constructor
     * @param nameIn Machine name
     * @param startIn Start time
     * @param endIn End time
     * @param reviewer Reviewed by
     * @param reviewed Reviewed on
     */
    public AuditReviewDto(String nameIn, Date startIn, Date endIn,
            String reviewer, Date reviewed) {
        this.id = 0L;
        this.name = nameIn;
        this.start = startIn;
        this.end = endIn;
        this.reviewedBy = reviewer;
        this.reviewedOn = reviewed;
    }

    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }

    /**
     * @return Returns the start time.
     */
    public Date getStart() {
        return start;
    }

    /**
     * @return Returns the end time.
     */
    public Date getEnd() {
        return end;
    }

    /**
     * @return Returns the reviewer.
     */
    public String getReviewedBy() {
        return reviewedBy;
    }

    /**
     * @return Returns the review date.
     */
    public Date getReviewedOn() {
        return reviewedOn;
    }

    /** {@inheritDoc} */
    public int compareTo(AuditReviewDto other) {
        return (int)(this.getStart().getTime() / 1000) -
            (int)(other.getStart().getTime() / 1000);
    }
}

// vim: ts=4:expandtab
