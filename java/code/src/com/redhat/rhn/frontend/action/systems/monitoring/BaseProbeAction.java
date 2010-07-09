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
package com.redhat.rhn.frontend.action.systems.monitoring;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.command.Command;
import com.redhat.rhn.domain.monitoring.command.CommandParameter;
import com.redhat.rhn.domain.monitoring.command.Metric;
import com.redhat.rhn.domain.monitoring.command.ParameterValidator;
import com.redhat.rhn.domain.monitoring.command.ThresholdParameter;
import com.redhat.rhn.domain.monitoring.notification.ContactGroup;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.monitoring.ModifyProbeCommand;

import org.apache.commons.collections.Transformer;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.util.LabelValueBean;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * Action for the probe details page. Note that there is no correpsonding
 * SetupAction since there isn't really a good separation between setup
 * and performing the action.
 *
 * @version $Rev: 53910 $
 */
public class BaseProbeAction extends RhnAction {

    private static Logger logger = Logger.getLogger(BaseProbeAction.class);

    protected static final String NOTIFICATION = "notification";
    public static final String PROBEID = RequestContext.PROBEID;
    public static final String SID = RequestContext.SID;
    public static final String METRICS = "metrics";
    public static final String STARTTS = "startts";
    public static final String ENDTS = "endts";
    protected static final String DESCR = "description";
    protected static final String CHECK_INTERVAL_MIN = "check_interval_min";
    protected static final String CONTACT_GROUP_ID = "contact_group_id";
    protected static final String NOTIFICATION_INTERVAL_MIN = "notification_interval_min";
    private static final String PASSWORD_PLACEHOLDER = "*pwd_placeholder*";

    /**
     * Create a list of localized intervals for notifications like '5 minutes'
     * or '2 hours'
     * @param req HttpServletRequest which will have an attribute set.
     */
    protected static void setIntervals(HttpServletRequest req) {
        List rv = new LinkedList();
        LocalizationService ls = LocalizationService.getInstance();
        rv.add(new LabelValueBean(ls.getMessage("probeeditaction.minute"), "1"));
        rv.add(new LabelValueBean(ls.getMessage("probeeditaction.minutes", "5"), "5"));
        rv.add(new LabelValueBean(ls.getMessage("probeeditaction.minutes", "10"), "10"));
        rv.add(new LabelValueBean(ls.getMessage("probeeditaction.minutes", "15"), "15"));
        rv.add(new LabelValueBean(ls.getMessage("probeeditaction.minutes", "30"), "30"));
        rv.add(new LabelValueBean(ls.getMessage("probeeditaction.minutes", "45"), "45"));
        rv.add(new LabelValueBean(ls.getMessage("probeeditaction.hour"), "60"));
        rv.add(new LabelValueBean(ls.getMessage("probeeditaction.hours", "2"), "120"));
        rv.add(new LabelValueBean(ls.getMessage("probeeditaction.hours", "6"), "360"));
        rv.add(new LabelValueBean(ls.getMessage("probeeditaction.hours", "12"), "720"));
        rv.add(new LabelValueBean(ls.getMessage("probeeditaction.hours", "24"), "1440"));
        req.setAttribute("intervals", rv);
    }

    /**
     * Get a list of the contact groups for <code>org</code>
     * as <code>LabelValueBeans</code>
     * @param orgIn the org for which to get the contact groups
     */
    protected static void setContactGroups(HttpServletRequest req, Org orgIn) {
        List rv = new LinkedList();
        Iterator i = orgIn.getContactGroups().iterator();
        while (i.hasNext()) {
            ContactGroup cg = (ContactGroup) i.next();
            rv.add(new LabelValueBean(cg.getContactGroupName(),
                                      cg.getId().toString()));
        }
        // Sort the list
        Collections.sort(rv);
        req.setAttribute("contactGroups", rv);
    }

    /**
     * Get the parameter values for <code>probe</code> as a list
     * of <code>CommandParameterValue</code> objects
     * @param probe the probe from which parameter values should be taken; if
     * it is <code>null</code>, the commands default values are used
     * @param command the command whose parameters to list
     * @param submitted whether the user submitted parameter values
     */
    protected static void setParamValueList(HttpServletRequest req,
            Probe probe, Command command, boolean submitted) {
        List result = new LinkedList();
        List thresholdParams = new LinkedList();
        ArrayList params = new ArrayList(command.getCommandParameters());
        Collections.sort(params, new CommandParameterComparator());
        Iterator i = params.iterator();
        String lastLabel = "";
        while (i.hasNext()) {
            CommandParameter cp = (CommandParameter) i.next();
            boolean isPassword = isPassword(cp);
            if (cp.isFieldVisible()) {
                String value = null;
                if (submitted) {
                    value = paramValue(cp, req);
                }
                else if (probe == null) {
                    value = cp.getDefaultValue();
                }
                else {
                    value = probe.getProbeParameterValue(cp).getValue();
                }
                boolean isThreshold = cp instanceof ThresholdParameter;
                Map map = getCommandParameterMap(cp, paramName(cp), value,
                        isThreshold, lastLabel);
                if (isThreshold) {
                    thresholdParams.add(map);
                }
                else {
                    result.add(map);
                }
                if (isPassword) {
                    // Add extra password confirm field
                    Map confirmmap = getCommandParameterMap(cp, paramName(cp) + "_confirm",
                            null, false, lastLabel);
                    String confirmLabel = (String) confirmmap.get("label");
                    confirmLabel = confirmLabel + "_confirm";
                    confirmmap.put("label", confirmLabel);
                    // Get rid of value from map
                    if (submitted) {
                        String requestParamName = paramName(cp) + "_confirm";
                        String confirmValue = req.getParameter(requestParamName);
                        confirmmap.put("value", confirmValue);
                    }
                    else {
                        if (value != null) {
                            map.put("value", PASSWORD_PLACEHOLDER);
                            confirmmap.put("value", PASSWORD_PLACEHOLDER);
                        }
                        else {
                            map.put("value", null);
                        }
                    }
                    result.add(confirmmap);
                }
            }
        }
        result.addAll(thresholdParams);
        req.setAttribute("paramValueList", result);
    }

    private static Map getCommandParameterMap(CommandParameter cp, String paramName,
            String value, boolean isThreshold, String lastLabel) {
        HashMap map = new HashMap();
        map.put("value", value);
        map.put("mandatory", Boolean.valueOf(cp.isMandatory()));
        String label = cp.getDescription();
        if (isThreshold) {
            ThresholdParameter tp = (ThresholdParameter) cp;
            label = tp.getMetric().getDescription();
            map.put("unit", tp.getMetric().getStorageUnitId());
            map.put("threshold", tp.getThresholdType().getName());
        }
        if (!lastLabel.equals(label)) {
            map.put("label", label);
        }
        lastLabel = label;
        map.put("fieldWidgetName", cp.getFieldWidgetName());
        map.put("paramName", paramName);
        map.put("maxLength", cp.getFieldMaximumLength());
        map.put("size", cp.getFieldVisibleLength());
        return map;
    }

    private static boolean isPassword(CommandParameter cp) {
        return cp.getFieldWidgetName().equals("password");
    }

    /**
     * Edit the probe according to the values submitted in <code>form</code>
     * and command parameters in the request parameters named <tt>param_*</tt>
     * @param cmd the command that wil modify the probe
     * @param form the submitted form
     * @param req the request
     */
    protected boolean editProbe(ModifyProbeCommand cmd, DynaActionForm form,
            HttpServletRequest req) {
        // Validate the form
        ActionErrors errors = RhnValidationHelper.validateDynaActionForm(
                BaseProbeAction.class, form);
        validateParameters(errors, cmd, req);
        validateInterval(errors, form);
        if (!errors.isEmpty()) {
            addErrors(req, errors);
            return false;
        }

        // Loop through the params and set the object value
        Iterator i = cmd.commandParametersIter();
        while (i.hasNext()) {
            CommandParameter cp = (CommandParameter) i.next();
            // In the JSP we pre-pend the "param_" so we can
            // keep the Command parameter values separate from the other
            // parameters.
            if (cp.isFieldVisible()) {
                String value = paramValue(cp, req);
                if (isPassword(cp) && value != null &&
                        value.equals(PASSWORD_PLACEHOLDER)) {
                    logger.debug("Password is existing and is the placeholder.");
                }
                else {
                    logger.debug("Setting param value.");
                    cmd.setParameterValue(cp, value);
                }
            }
        }
        cmd.setDescription(form.getString(DESCR));
        cmd.setNotification((Boolean) form.get(NOTIFICATION));
        cmd.setCheckIntervalMinutes((Long) form.get("check_interval_min"));
        cmd.setNotificationIntervalMinutes((Long) form
                .get("notification_interval_min"));
        cmd.setContactGroup((Long) form.get("contact_group_id"));
        cmd.storeProbe();

        return true;
    }

    // Check to make sure they didn't set the notif interval to be
    // less than the check interval.
    private void validateInterval(ActionErrors errors, DynaActionForm form) {
        if (form.get("check_interval_min") != null &&
                form.get("notification_interval_min") != null) {
            long cim = ((Long) form.get("check_interval_min")).longValue();
            long nim = ((Long) form.get("notification_interval_min")).longValue();
            if (nim < cim) {
                addGlobalMessage(errors, "probedit.checklessthannotif");
            }
        }
    }

    private void validateParameters(ActionErrors errors,
            ModifyProbeCommand cmd, HttpServletRequest req) {
        LocalizationService ls = LocalizationService.getInstance();
        for (Iterator i = cmd.commandParametersIter(); i.hasNext();) {
            CommandParameter cp = (CommandParameter) i.next();
            if (cp.isFieldVisible()) {
                String name = ls.getMessage(cp.getDescription());
                String value = paramValue(cp, req);
                ParameterValidator v = cp.getValidator();
                if (value == null && v.isMandatory()) {
                    addGlobalMessage(errors, "probeparam.mandatory", name);
                }
                else if (cp.getFieldWidgetName().equals("password")) {
                    String confirmParamName = paramName(cp);
                    String valueConfirm = req.getParameter(confirmParamName +
                            "_confirm");
                    valueConfirm = cp.getValidator().normalize(valueConfirm);
                    // If the passwords dont match, warn the user
                    if (logger.isDebugEnabled()) {
                        logger.debug("v        : " + value);
                        logger.debug("vc       : " + valueConfirm);
                        logger.debug("1st cond : " +
                                StringUtils.equals(value, valueConfirm));
                        logger.debug("2nd cond : " +
                                StringUtils.equals(value, PASSWORD_PLACEHOLDER));
                    }
                    if (!StringUtils.equals(value, valueConfirm) &&
                            !StringUtils.equals(value, PASSWORD_PLACEHOLDER)) {
                        ActionMessage m = new ActionMessage("probeparam.passnomatch",
                                name, value, null);
                        errors.add(ActionMessages.GLOBAL_MESSAGE, m);
                    }
                }
                else if (!v.isConvertible(value)) {
                    String typeName = ls.getMessage(v.getTypeKey());
                    ActionMessage m = new ActionMessage("probeparam.illegal",
                            name, value, typeName);
                    errors.add(ActionMessages.GLOBAL_MESSAGE, m);
                }
                else if (!v.inRange(value)) {
                    ActionMessage m = null;
                    if (cp.getMinValue() == null) {
                        m = new ActionMessage("probeparam.toolarge", name,
                                value, cp.getMaxValue());
                    }
                    else if (cp.getMaxValue() == null) {
                        m = new ActionMessage("probeparam.toosmall", name,
                                value, cp.getMinValue());
                    }
                    else {
                        m = new ActionMessage("probeparam.notbetween", name,
                                value, cp.getMinValue(), cp.getMaxValue());
                    }
                    errors.add(ActionMessages.GLOBAL_MESSAGE, m);
                }
            }
        }
        // Check that the values for threshold params are
        // in ascending order for each metric
        Command c = cmd.getCommand();
        ToParamValue toParamValue = new ToParamValue(req);
        for (Iterator i = c.getMetrics().iterator(); i.hasNext();) {
            Metric m = (Metric) i.next();
            ArrayList v = c.checkAscendingValues(m, toParamValue);
            for (Iterator j = v.iterator(); j.hasNext();) {
                ThresholdParameter p1 = (ThresholdParameter) j.next();
                String v1 = (String) j.next();
                ThresholdParameter p2 = (ThresholdParameter) j.next();
                String v2 = (String) j.next();
                String mlabel = ls.getMessage(m.getDescription());
                String plabel1 = ls.getMessage(p1.getThresholdType().getName());
                String plabel2 = ls.getMessage(p2.getThresholdType().getName());
                ActionMessage am = new ActionMessage("probeparam.threshold.inverted",
                        new Object[] {mlabel,
                            plabel1, v1,
                            plabel2, v2});
                errors.add(ActionMessages.GLOBAL_MESSAGE, am);
            }
        }
    }

    private static String paramValue(CommandParameter cp, HttpServletRequest req) {
        String requestParamName = paramName(cp);
        String value = req.getParameter(requestParamName);
        return cp.getValidator().normalize(value);
    }

    private static String paramName(CommandParameter cp) {
        return "param_" + cp.getParamName();
    }

    private static final class CommandParameterComparator implements Comparator {

        /**
         * {@inheritDoc}
         */
        public int compare(Object o1, Object o2) {
            CommandParameter p1 = (CommandParameter) o1;
            CommandParameter p2 = (CommandParameter) o2;
            return p1.getFieldOrder().compareTo(p2.getFieldOrder());
        }

    }

    private static final class ToParamValue implements Transformer {
        private HttpServletRequest req;
        public ToParamValue(HttpServletRequest req0) {
            req = req0;
        }

        public Object transform(Object input) {
            return paramValue((CommandParameter) input, req);
        }

    }
}
