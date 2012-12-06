/**
 * Copyright (c) 2009--2011 Red Hat, Inc.
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

import java.sql.Timestamp;

/**
 * PackageChangelogDto
 * @version $Rev$
 *
 * DTO for a specific set of package capability data returned from some data source
 * package queries.
 */
public class PackageChangelogDto extends BaseDto {

    private Long id;
    private String author;
    private String text;
    private Timestamp time;


    /**
     * @return the id
     */
    public Long getId() {
        return id;
    }

    /**
     * @param idIn the id to set
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * @return the author
     */
    public String getAuthor() {
        return author;
    }

    /**
     * @param authorIn the author to set
     */
    public void setAuthor(String authorIn) {
        this.author = authorIn;
    }

    /**
     * @return the text
     */
    public String getText() {
        return text;
    }

    /**
     * @param textIn the text to set
     */
    public void setText(String textIn) {
        this.text = textIn;
    }

    /**
     * @return the time
     */
    public Timestamp getTime() {
        return time;
    }

    /**
     * @param timeIn the time to set
     */
    public void setTime(Timestamp timeIn) {
        this.time = timeIn;
    }
}
