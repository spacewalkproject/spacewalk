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

import com.redhat.rhn.common.util.Asserts;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;

/**
 * Filter - Class representation of the table rhn_redirects.
 * @version $Rev: 1 $
 */
public class Filter {

    private Long id;
    private String description;
    private String reason;
    private Date expiration;
    private String lastUpdateUser;
    private Date lastUpdateDate;
    private Date startDate;
    private Boolean recurring;
    private Long recurringFrequency;
    private Long recurringDuration;
    private Long recurringDurationType;

    private Org org;
    private User user;
    private FilterType type;
    private Set criteria;
    private Set emailAddresses;

    /**
     * Add a match criteria of the given type that matches
     * against <code>value</code>
     * @param matchType the type of match for the criteria
     * @param value the value to match against
     * @return the new criteria that has been added to this filter
     */
    public Criteria addCriteria(MatchType matchType, String value) {
        Asserts.assertNotNull(matchType, "matchType");
        Asserts.assertNotNull(value, "value");
        Criteria result = new Criteria();
        result.setMatchType(matchType);
        result.setValue(value);
        result.setFilter(this);
        if (getCriteria() == null) {
            setCriteria(new HashSet());
        }
        getCriteria().add(result);
        return result;
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
     * Getter for description
     * @return String to get
    */
    public String getDescription() {
        return this.description;
    }

    /**
     * Setter for description
     * @param descriptionIn to set
    */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
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
     * Getter for expiration
     * @return Date to get
    */
    public Date getExpiration() {
        return this.expiration;
    }

    /**
     * Setter for expiration
     * @param expirationIn to set
    */
    public void setExpiration(Date expirationIn) {
        this.expiration = expirationIn;
    }

    /**
     * Getter for lastUpdateUser
     * @return String to get
    */
    public String getLastUpdateUser() {
        return this.lastUpdateUser;
    }

    /**
     * Setter for lastUpdateUser
     * @param lastUpdateUserIn to set
    */
    public void setLastUpdateUser(String lastUpdateUserIn) {
        this.lastUpdateUser = lastUpdateUserIn;
    }

    /**
     * Getter for lastUpdateDate
     * @return Date to get
    */
    public Date getLastUpdateDate() {
        return this.lastUpdateDate;
    }

    /**
     * Setter for lastUpdateDate
     * @param lastUpdateDateIn to set
    */
    public void setLastUpdateDate(Date lastUpdateDateIn) {
        this.lastUpdateDate = lastUpdateDateIn;
    }

    /**
     * Getter for startDate
     * @return Date to get
    */
    public Date getStartDate() {
        return this.startDate;
    }

    /**
     * Setter for startDate
     * @param startDateIn to set
    */
    public void setStartDate(Date startDateIn) {
        this.startDate = startDateIn;
    }


    /**
     * @return Returns the recurring.
     */
    public Boolean getRecurring() {
        return recurring;
    }



    /**
     * @param recurringIn The recurring to set.
     */
    public void setRecurring(Boolean recurringIn) {
        this.recurring = recurringIn;
    }



    /**
     * Get the number of minutes we want the recurring filter
     * to run for.  So, if we say the filter is for 30 minutes
     * then each time it runs, it will run for 30 minutes.
     *
     * @return Returns the recurringDuration.
     */
    public Long getRecurringDuration() {
        return recurringDuration;
    }



    /**
     * Set the number of minutes we want the recurring filter
     * to run for.  So, if we say the filter is for 30 minutes
     * then each time it runs, it will run for 30 minutes.
     *
     * @param recurringDurationIn The recurringDuration to set.
     */
    public void setRecurringDuration(Long recurringDurationIn) {
        this.recurringDuration = recurringDurationIn;
    }

    /**
     * @return Returns the recurringDurationType.
     */
    public Long getRecurringDurationType() {
        return recurringDurationType;
    }

    /**
     * @param recurringDurationTypeIn The recurringDurationType to set.
     */
    public void setRecurringDurationType(Long recurringDurationTypeIn) {
        this.recurringDurationType = recurringDurationTypeIn;
    }


    /**
     * How often this Filter recurrs.
     *
     * These values correspond to the constants defined in java.util.Calendar:
     *    public final static int DAY_OF_YEAR = 6;
     *    public final static int WEEK_OF_YEAR = 3;
     *    public final static int MONTH = 2;
     *
     * @return Returns the recurringFrequency.
     */
    public Long getRecurringFrequency() {
        return recurringFrequency;
    }



    /**
     * How often this Filter recurrs.
     *
     * These values correspond to the constants defined in java.util.Calendar:
     *    public final static int DAY_OF_YEAR = 6;
     *    public final static int WEEK_OF_YEAR = 3;
     *    public final static int MONTH = 2;

     * @param recurringFrequencyIn The recurringFrequency to set.
     */
    public void setRecurringFrequency(Long recurringFrequencyIn) {
        this.recurringFrequency = recurringFrequencyIn;
    }


    /**
     * @return Returns the org.
     */
    public Org getOrg() {
        return org;
    }

    /**
     * @param orgIn The org to set.
     */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }

    /**
     * @return Returns the user.
     */
    public User getUser() {
        return user;
    }

    /**
     * @param userIn The user to set.
     */
    public void setUser(User userIn) {
        this.user = userIn;
    }


    /**
     * @return Returns the type.
     */
    public FilterType getType() {
        return type;
    }


    /**
     * @param typeIn The type to set.
     */
    public void setType(FilterType typeIn) {
        this.type = typeIn;
    }



    /**
     * @return Returns the criteria.
     */
    public Set getCriteria() {
        return criteria;
    }



    /**
     * @param criteria The criteria to set.
     */
    private void setCriteria(Set criteria0) {
        this.criteria = criteria0;
    }


    /**
     * @return Returns the emailAddresses.
     */
    public Set getEmailAddresses() {
        if (emailAddresses == null) {
            emailAddresses = new HashSet();
        }
        return emailAddresses;
    }


    /**
     * @param emailAddresses The emailAddresses to set.
     */
    private void setEmailAddresses(Set emailAddresses0) {
        this.emailAddresses = emailAddresses0;
    }


}
