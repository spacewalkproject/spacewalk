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
package com.redhat.rhn.manager.monitoring;

import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.notification.Criteria;
import com.redhat.rhn.domain.monitoring.notification.Filter;
import com.redhat.rhn.domain.monitoring.notification.MatchType;
import com.redhat.rhn.domain.monitoring.notification.NotificationFactory;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.StringUtils;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

/**
 * A command to create or edit filters
 * @version $Rev$
 */
public class ModifyFilterCommand {

    private static final HashSet PROBE_STATE_SET =
        new HashSet(Arrays.asList(MonitoringConstants.PROBE_STATES));

    private User user;
    private Filter filter;
    private Date now;

    /**
     * Create a command that modifies a new filter.
     * @param user0 the user modifying the filter
     */
    public ModifyFilterCommand(User user0) {
        user = user0;
        filter = new Filter();
        filter.setUser(user);
        filter.setOrg(user.getOrg());
        filter.setType(NotificationFactory.FILTER_TYPE_REDIR);
        filter.setRecurring(Boolean.FALSE);
        now = new Date();
        Calendar sevenDays = Calendar.getInstance();
        sevenDays.add(Calendar.DAY_OF_YEAR, 7);
        filter.setExpiration(sevenDays.getTime());
        filter.setStartDate(now);
    }

    /**
     * Create a command that modifies the existing filter
     * with the given ID for user <code>user0</code>
     * @param filterID the ID of the filter to modify
     * @param user0 the user modifying the filter
     */
    public ModifyFilterCommand(Long filterID, User user0) {
        user = user0;
        filter = MonitoringManager.getInstance().lookupFilter(filterID,
                user0);
    }

    /**
     * Return the filter that is modified by this command
     * @return the filter that is modified by this command
     */
    public Filter getFilter() {
        return filter;
    }

    /**
     * Set the start date of the filter
     * @param v the new start date
     */
    public void setStartDate(Date v) {
        filter.setStartDate(v);
    }

    /**
     * Set the expiration date of the filter
     * @param v the expiration date
     */
    public void setExpiration(Date v) {
        filter.setExpiration(v);
    }

    /** Set the expiration/start of the Filter to be in the
     * past so it will no longer be active.
     */
    public void expireFilter() {
        long ctime = System.currentTimeMillis();
        filter.setStartDate(new Timestamp(ctime - 1000));
        filter.setExpiration(new Timestamp(ctime));
    }

    /**
     * Set the description of the filter
     * @param v the new description
     */
    public void setDescription(String v) {
        filter.setDescription(v);
    }

    /**
     * Update the recurrance logic of the filter. If <code>recurring</code> is
     * {@link Boolean#TRUE}, set the filter to be active for <code>duration</code>
     * time units every <code>frequency</code>; the time units are given
     * by <code>durationType</code>. The frequency is one of the constants mentioned in
     * {@link Filter#setRecurringFrequency}
     * @param recurring whether the filter is recurring or not
     * @param duration the number of time units the filter is active for
     * @param durationType one of {@link Calendar#YEAR}, {@link Calendar#WEEK_OF_YEAR},
     *        {@link Calendar#DAY_OF_MONTH}, {@link Calendar#HOUR_OF_DAY},
     *        {@link Calendar#HOUR_OF_DAY}
     * @param frequency the frequency with which the filter is activated, as described in
     * {@link Filter#setRecurringFrequency}
     */
    public void updateRecurring(Boolean recurring, int duration, int durationType,
            Long frequency) {
        filter.setRecurring(recurring);

        if (recurring.booleanValue()) {
            // Calculate duration
            Calendar expires = Calendar.getInstance();
            expires.setTime(filter.getStartDate());
            expires.add(durationType, duration);
            if (durationType == Calendar.MINUTE) {
                // durationType == 12
                // NOOP since minutes is the base type.
            }
            else if (durationType == Calendar.HOUR_OF_DAY) {
                // durationType == 11
                duration = duration * 60;
            }
            else if (durationType == Calendar.DAY_OF_MONTH) {
                // durationType == 5
                duration = duration * 60 * 24;
            }
            else if (durationType == Calendar.WEEK_OF_YEAR) {
                // durationType == 3
                duration = duration * 60 * 24 * 7;
            }
            else if (durationType == Calendar.YEAR) {
                // durationType == 1
                duration = duration * 60 * 24 * 7 * 365;
            }
            else {
                throw new IllegalArgumentException("Durration for recurring " +
                        "should be either Calendar.MINUTE, HOURS_OF_DAY, " +
                        "DAY_OF_MONTH, WEEK_OF_YEAR, YEAR");
            }
            filter.setRecurringDuration(new Long(duration));
            filter.setRecurringFrequency(frequency);
            filter.setRecurringDurationType(new Long(durationType));
        }
    }

    /**
     * Disable recurring for this Filter.  This sets the:
     *
     * filter.recurring = false
     * filter.recurringduration = null
     * filter.recurringdurationtype = null
     *
     */
    public void disableRecurring() {
        filter.setRecurring(Boolean.FALSE);
        filter.setRecurringDuration(null);
        filter.setRecurringDurationType(null);
    }

    /**
     * Set the type of the filter
     * @param filterType the new filter type
     */
    public void setFilterType(String filterType) {
        filter.setType(NotificationFactory.lookupFilterType(filterType));
    }

    /**
     * Store the filter
     */
    public void storeFilter() {
        MonitoringManager.getInstance().storeFilter(filter, user);
    }

    /**
     * Update the scope of the filter to only match on the values
     * given in <code>values</code>
     * @param mt the match type
     * @param values the objects
     */
    public void updateScope(MatchType mt, String[] values) {
        updateCriteria(mt, values);
    }

    /**
     * Get the scope for the match type of the filter, defaults to the
     * scope of {@link MatchType#SCOUT}
     *
     * @return the scope for the match type of the filter
     */
    public String getScope() {
        // This assumes that all match types in CAT_SCOPE
        // have identical scope. This is currently enforced by updateScope
        Set l = getCriteria();
        for (Iterator i = l.iterator(); i.hasNext();) {
            MatchType mt = ((Criteria) i.next()).getMatchType();
            if (MatchType.CAT_SCOPE.equals(mt.getCategory())) {
                return mt.getScope();
            }
        }
        return MatchType.ORG.getScope();
    }

    /**
     * Update the probe states for which the filter matches to <code>values</code>.
     * The values must be one of the constants in {@link MonitoringConstants#PROBE_STATES}
     * @param values the new probe state values on which the filter matches
     */
    public void updateStates(String[] values) {
        if (values != null) {
            HashSet valueSet = new HashSet(Arrays.asList(values));
            if (PROBE_STATE_SET.equals(valueSet)) {
                values = null;
            }
            valueSet.removeAll(PROBE_STATE_SET);
            if (valueSet.size() > 0) {
                throw new IllegalArgumentException("The state values must be one of " +
                        PROBE_STATE_SET + ", but also contained " + valueSet);
            }
        }
        updateCriteria(MatchType.STATE, values);
    }

    /**
     * Update the criteria with a match type in <code>rangeSet</code> so that
     * they are all of match type <code>mt</code> and match on the given
     * <code>values</code>. In other words, delete all the criteria with a match type
     * in <code>rangeSet</code> and add new ones with the given match type and values.
     * The routine tries to avoid unnecessary deletions and reinsertions of criteria.
     */
    private void updateCriteria(MatchType mt, String[] values) {
        Set rangeSet = MatchType.typesInCategory(mt.getCategory());
        Set s = getCriteria();
        if (values == null) {
            values = new String[0];
        }
        Set newValues = new HashSet(Arrays.asList(values));
        for (Iterator i = s.iterator(); i.hasNext();) {
            Criteria c = (Criteria) i.next();
            if (rangeSet.contains(c.getMatchType())) {
                if (mt.equals(c.getMatchType()) && newValues.contains(c.getValue())) {
                    newValues.remove(c.getValue());
                }
                else {
                    i.remove();
                }
            }
        }
        // newValues contains all the values for which we don't
        // have a criteria yet
        for (Iterator i = newValues.iterator(); i.hasNext();) {
            String v = (String) i.next();
            if (!StringUtils.isBlank(v)) {
                filter.addCriteria(mt, v);
            }
        }
    }

    /**
     * Return the values of all criteria that have the
     * given match type
     * @param mt the match type for which to return criteria values
     * @return the values of criteria with the given match type
     */
    public String[] getCriteriaValues(MatchType mt) {
        ArrayList result = new ArrayList();
        for (Iterator i = getCriteria().iterator(); i.hasNext();) {
            Criteria c = (Criteria) i.next();
            if (mt.equals(c.getMatchType())) {
                result.add(c.getValue());
            }
        }
        return (String[]) result.toArray(new String[result.size()]);
    }

    private Set getCriteria() {
        Set result = filter.getCriteria();
        return (result == null) ? Collections.EMPTY_SET : result;
    }

    /**
     * Update the criteria related to pattern matching on filter output. If
     * <code>match</code> is <code>null</code>, all match related criteria
     * will be removed. If it is non-null, all match related criteria are
     * replaced by one criterion that matches on the given <code>match</code>
     * string.
     * @param pattern the regex pattern to match against. This must be a valid
     * Perl5 regex.
     * @param matchCase whether the regex match should be case-sensitive or not
     */
    public void updateMatch(String pattern, Boolean matchCase) {
        String[] values = new String[] { pattern };
        if (StringUtils.isBlank(pattern)) {
            values = new String[0];
        }
        boolean withCase = matchCase == null ? false : matchCase.booleanValue();
        MatchType mt = withCase ? MatchType.REGEX_CASE : MatchType.REGEX;
        updateCriteria(mt, values);
    }

    /**
     * Update the criteria that filter by contact group. If <code>groups</code>
     * is <code>null</code> or an empty array, all criteria matching on
     * contact group will be deleted.
     * @param groups the new groups to filter by.
     */
    public void updateContactGroups(String[] groups) {
        updateCriteria(MatchType.CONTACT, groups);
    }

    /**
     * Set the email addresses for this filter to the
     * <code>addresses</code>
     * @param addresses the new list of email addresses
     */
    public void setEmailAddresses(String[] addresses) {
        filter.getEmailAddresses().clear();
        filter.getEmailAddresses().addAll(Arrays.asList(addresses));
    }

}
