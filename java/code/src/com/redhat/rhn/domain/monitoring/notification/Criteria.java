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
package com.redhat.rhn.domain.monitoring.notification;


/**
 * A match criteria for notification filters, maps the table
 * <code>rhn_redirect_criteria</code>
 * @version $Rev$
 */
public class Criteria {

    private Long   id;
    private String match;
    private String value;
    private boolean inverted;
    private Filter filter;

    /**
     * Create a new object
     */
    Criteria() {
        setInverted(false);
    }

    /**
     * @return Returns the filter.
     */
    public Filter getFilter() {
        return filter;
    }

    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * @return Returns the inverted.
     */
    private boolean isInverted() {
        return inverted;
    }

    /**
     * @return Returns the match.
     */
    private String getMatch() {
        return match;
    }

    /**
     * @return the match type
     */
    public MatchType getMatchType() {
        return MatchType.findMatchType(getMatch());
    }

    /**
     * @return Returns the value.
     */
    public String getValue() {
        return value;
    }

    /**
     * @param filter0 The filter to set.
     */
    void setFilter(Filter filter0) {
        this.filter = filter0;
    }

    /**
     * @param id The id to set.
     */
    private void setId(Long id0) {
        this.id = id0;
    }

    /**
     * @param inverted The inverted to set.
     */
    private void setInverted(boolean inverted0) {
        this.inverted = inverted0;
    }

    /**
     * @param match The match to set.
     */
    private void setMatch(String match0) {
        this.match = match0;
    }

    /**
     * @param v The value to set.
     */
    public void setValue(String v) {
        this.value = v;
    }

    /**
     * Set the match type
     * @param v the new match type
     */
    public void setMatchType(MatchType v) {
        setMatch(v.getName());
    }

}
