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
package com.redhat.rhn.frontend.action.monitoring.notification;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.notification.Filter;
import com.redhat.rhn.domain.monitoring.notification.MatchType;
import com.redhat.rhn.domain.monitoring.notification.NotificationFactory;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.action.common.DateRangePicker;
import com.redhat.rhn.frontend.action.common.DateRangePicker.DatePickerResults;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.monitoring.ModifyFilterCommand;
import com.redhat.rhn.manager.monitoring.MonitoringManager;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.math.NumberUtils;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BaseFilterEditAction - renders and saves a notification Filter
 * @version $Rev: 53528 $
 */
public abstract class BaseFilterEditAction extends RhnAction {

    private static final String FILTER = "filter";
    private static final String SCOPE = "scope";
    private static final String PROBE = "probe";
    public  static final String SCOUT = "scout";
    public  static final String ORG   = "org";
    private static final String SCOPES = "scopes";
    private static final String STATES = "states";
    private static final String DEST = "destination";

    public static final String DESCRIPTION = "description";
    public static final String RECURRING = "recurring";
    public static final String RECURRING_DURATION = "recurring_duration";
    public static final String DURATION_TYPES = "duration_types";
    public static final String RECURRING_FREQUENCY = "recurring_frequency";
    public static final String FREQUENCY_TYPES = "frequency_types";
    public static final String FILTER_TYPE = "filterType";

    public static final String DURATION_TYPE = "duration_type";
    private static final String MATCH = "output_match";
    private static final String MATCH_CASE = "output_match_case";
    private static final String CONTACT_GROUPS = "contact_groups";
    private static final String CONTACT_GROUPS_ALL = "all";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest req, HttpServletResponse resp) {
        DynaActionForm form = (DynaActionForm) formIn;

        RequestContext rctx = new RequestContext(req);
        ModifyFilterCommand cmd = makeModifyFilterCommand(rctx);
        Filter filter = cmd.getFilter();
        // We always set the filter as a request attribute, so that the
        // tests can find it even if the JSP doesn't need it
        req.setAttribute(FILTER, filter);

        // Default to 7 days from today
        DateRangePicker picker =
            new DateRangePicker(form, req, filter.getStartDate(),
                    filter.getExpiration(), DatePicker.YEAR_RANGE_POSITIVE,
                    "filter-form.jspf.start_date",
                    "filter-form.jspf.expire_date");
        DatePickerResults dates = picker.processDatePickers(isSubmitted(form));

        if (isSubmitted(form)) {
            ActionErrors errors = RhnValidationHelper.validateDynaActionForm(
                    this, form);
            validateMatch(errors, form);
            String[] addresses = validateDestination(errors, form);
            errors.add(dates.getErrors());
            if (!errors.isEmpty()) {
                getStrutsDelegate().saveMessages(req, errors);
            }
            else {
                processDates(form, cmd, dates);
                processScope(form, cmd);
                processMatch(form, cmd);
                processContactGroups(form, cmd);
                cmd.updateStates(form.getStrings(STATES));
                cmd.setDescription(form.getString("description"));
                String filterType = form.getString(FILTER_TYPE);
                cmd.setFilterType(filterType);
                cmd.setEmailAddresses(addresses);
                cmd.storeFilter();
                createSuccessMessage(req, getSuccessKey(), filter.getDescription());
                return mapping.findForward("success");
            }
        }
        else {
            // Fill out the form from the Filter itself
            form.set(RECURRING, filter.getRecurring());
            // Since RECURRING_DURATION is a user inputable field
            // we have to convert it to a string and also protect against nulls
            if (filter.getRecurringDuration() != null) {
                // We need to convert the recurring duration to the right digits
                form.set(RECURRING_DURATION,
                        getRecurringDigits(filter.getRecurringDuration(),
                                filter.getRecurringDurationType().intValue()));
                form.set(DURATION_TYPE, filter.getRecurringDurationType());
            }
            form.set(DESCRIPTION, filter.getDescription());
            form.set(RECURRING_FREQUENCY, filter.getRecurringFrequency());
            form.set(SCOPE, cmd.getScope());
            form.set(ORG, cmd.getCriteriaValues(MatchType.ORG));
            form.set(SCOUT, cmd.getCriteriaValues(MatchType.SCOUT));
            form.set(PROBE, cmd.getCriteriaValues(MatchType.PROBE));
            form.set(FILTER_TYPE, filter.getType().getName());
            String[] states = cmd.getCriteriaValues(MatchType.STATE);
            if (states.length == 0) {
                states = MonitoringConstants.PROBE_STATES;
            }
            form.set(STATES, states);
            String[] groups = cmd.getCriteriaValues(MatchType.CONTACT);
            if (groups.length == 0) {
                groups = new String[] { CONTACT_GROUPS_ALL };
            }
            form.set(CONTACT_GROUPS, groups);
            ArrayList l = new ArrayList(filter.getEmailAddresses());
            String dest = StringUtils.join(l.toArray(new String[l.size()]), ',');
            form.set(DEST, dest);
        }

        req.setAttribute("filterTypes", NotificationFactory.listFilterTypes());
        req.setAttribute(SCOPES, makeScopes());
        req.setAttribute(STATES, makeStates());
        req.setAttribute(FREQUENCY_TYPES, makeFrequencyTypes());
        req.setAttribute(DURATION_TYPES, makeDurationTypes());
        ArrayList orgs = new ArrayList();
        Org org = rctx.getCurrentUser().getOrg();
        orgs.add(org);
        if (form.getStrings(ORG) == null || form.getStrings(ORG).length == 0) {
            form.set(ORG, new String[] { org.getId().toString() });
        }
        req.setAttribute(ORG, orgs);
        Set scouts = MonitoringManager.getInstance().
                listScouts(rctx.getCurrentUser());
        if (form.getStrings(SCOUT) == null || form.getStrings(SCOUT).length == 0) {
            SatCluster scout = (SatCluster) scouts.iterator().next();
            form.set(SCOUT, new String[] { scout.getId().toString() });
        }
        req.setAttribute(SCOUT, scouts);
        DataResult probes = MonitoringManager.getInstance().
                listProbes(rctx.getCurrentUser());
        req.setAttribute(PROBE, probes);
        DataResult groups = MonitoringManager.getInstance().
            listContactGroups(rctx.getCurrentUser());
        req.setAttribute(CONTACT_GROUPS, groups);
        return mapping.findForward("default");
    }



    private void processContactGroups(DynaActionForm form, ModifyFilterCommand cmd) {
        String[] groups = form.getStrings(CONTACT_GROUPS);
        if (ArrayUtils.contains(groups, CONTACT_GROUPS_ALL)) {
            // Erase any restriction by contact group
            groups = new String[0];
        }
        cmd.updateContactGroups(groups);
    }

    private void validateMatch(ActionErrors errors, DynaActionForm form) {
        String match = form.getString(MATCH);
        if (StringUtils.isBlank(match)) {
            return;
        }
        Throwable error = null;
        try {
            Pattern.compile(match);
        }
        catch (PatternSyntaxException e) {
            error = e;
        }
        catch (IllegalArgumentException e) {
            error = e;
        }
        if (error != null) {
            ActionMessage msg = new ActionMessage(error.getMessage());
            errors.add(MATCH, msg);
        }
    }


    private String[] validateDestination(ActionErrors errors, DynaActionForm form) {
        String dest = form.getString(DEST);
        if (StringUtils.isBlank(dest)) {
            return new String[0];
        }
        String[] addr = StringUtils.split(dest, ",");
        for (int i = 0; i < addr.length; i++) {
            addr[i] = StringUtils.strip(addr[i]);
            if (!RhnValidationHelper.isValidEmailAddress(addr[i])) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("error.addr_invalid", addr[i]));
            }
        }
        return addr;
    }

    private void processMatch(DynaActionForm form, ModifyFilterCommand cmd) {
        String match = form.getString(MATCH);
        Boolean matchCase = (Boolean) form.get(MATCH_CASE);
        cmd.updateMatch(match, matchCase);
    }

    private void processScope(DynaActionForm form, ModifyFilterCommand cmd) {
        String scope = form.getString(SCOPE);
        MatchType mt = null;
        Set scopeSet = MatchType.typesInCategory(MatchType.CAT_SCOPE);
        for (Iterator i = scopeSet.iterator(); i.hasNext();) {
            MatchType t = (MatchType) i.next();
            if (t.getScope().equals(scope)) {
                mt = t;
                break;
            }
        }
        if (mt == null) {
            throw new IllegalArgumentException("Unknwon scope " + scope);
        }
        cmd.updateScope(mt, form.getStrings(scope));
    }


    private void processDates(DynaActionForm form, ModifyFilterCommand cmd,
            DatePickerResults dates) {
        Boolean recurring = (Boolean) form.get(RECURRING);
        int duration = 0;
        if (recurring.booleanValue()) {
            String s = form.getString(RECURRING_DURATION);
            duration = NumberUtils.createInteger(s).intValue();
            int durationType = ((Long) form.get(DURATION_TYPE)).intValue();
            Long frequency = (Long) form.get(RECURRING_FREQUENCY);
            cmd.updateRecurring(recurring, duration, durationType, frequency);
        }
        else {
            cmd.disableRecurring();
        }
        cmd.setStartDate(dates.getStart().getDate());
        cmd.setExpiration(dates.getEnd().getDate());
    }


    private List makeScopes() {
        ArrayList result = new ArrayList();
        result.add(lv("filter-form.jspf.org", MatchType.ORG.getScope()));
        result.add(lv("filter-form.jspf.scout", MatchType.SCOUT.getScope()));
        result.add(lv("filter-form.jspf.probe", MatchType.PROBE.getScope()));
        localize(result);
        return result;
    }

    private List makeDurationTypes() {
        ArrayList result = new ArrayList();
        result.add(lv("filter-form.jspf.minutes",
                new Long(Calendar.MINUTE).toString()));
        result.add(lv("filter-form.jspf.hours",
                new Long(Calendar.HOUR_OF_DAY).toString()));
        result.add(lv("filter-form.jspf.days",
                new Long(Calendar.DAY_OF_YEAR).toString()));
        result.add(lv("filter-form.jspf.weeks",
                new Long(Calendar.WEEK_OF_YEAR).toString()));
        result.add(lv("filter-form.jspf.years",
                new Long(Calendar.YEAR).toString()));
        localize(result);
        return result;
    }

    private List makeFrequencyTypes() {
        ArrayList result = new ArrayList();
        result.add(lv("filter-form.jspf.daily",
                new Long(Calendar.DAY_OF_YEAR).toString()));
        result.add(lv("filter-form.jspf.weekly",
                new Long(Calendar.WEEK_OF_YEAR).toString()));
        result.add(lv("filter-form.jspf.monthly",
                new Long(Calendar.MONTH).toString()));
        localize(result);
        return result;
    }

    private List makeStates() {
        ArrayList result = new ArrayList();
        result.add(lv("filter-form.jspf.ok", MonitoringConstants.PROBE_STATE_OK));
        result.add(lv("filter-form.jspf.pending", MonitoringConstants.PROBE_STATE_PENDING));
        result.add(lv("filter-form.jspf.warn", MonitoringConstants.PROBE_STATE_WARN));
        result.add(lv("filter-form.jspf.crit", MonitoringConstants.PROBE_STATE_CRITICAL));
        result.add(lv("filter-form.jspf.unknown", MonitoringConstants.PROBE_STATE_UNKNOWN));
        return result;
    }

    private String getRecurringDigits(Long durationIn, int durationTypeIn) {
        long duration = durationIn.longValue();
        if (durationTypeIn == Calendar.MINUTE) {
            // durationType == 12
            // NOOP since minutes is the base type.
        }
        else if (durationTypeIn == Calendar.HOUR_OF_DAY) {
            // durationType == 11
            duration = duration / 60;
        }
        else if (durationTypeIn == Calendar.DAY_OF_MONTH) {
            // durationType == 5
            duration = duration / 60 / 24;
        }
        else if (durationTypeIn == Calendar.WEEK_OF_YEAR) {
            // durationType == 3
            duration = duration / 60 / 24 / 7;
        }
        else if (durationTypeIn == Calendar.YEAR) {
            // durationType == 1
            duration = duration / 60 / 24 / 7 / 365;
        }
        else {
            throw new IllegalArgumentException("Durration for recurring " +
                    "should be either Calendar.MINUTE, HOURS_OF_DAY, " +
                    "DAY_OF_MONTH, WEEK_OF_YEAR, YEAR");
        }
        return new Long(duration).toString();
    }


    /**
     * Key for the success message
     * @return String key
     */
    public abstract String getSuccessKey();

    /**
     * Create a new command to modify the filter
     * @param ctx the current request
     * @return a new command to modify the filter
     */
    protected abstract ModifyFilterCommand makeModifyFilterCommand(RequestContext ctx);

}
