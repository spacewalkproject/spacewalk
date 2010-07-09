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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.BaseKickstartCommand;
import com.redhat.rhn.manager.kickstart.KickstartLocaleCommand;

import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;

/**
 * Handles display and update of Kickstart -> System Details -> Locale
 *
 * @version $Rev$
 */
public class KickstartLocaleEditAction extends BaseKickstartEditAction {

    public static final String TIMEZONE_OPTIONS = "timezones";
    public static final String TIMEZONE = "timezone";
    public static final String USE_UTC = "use_utc";
    public static final String UPDATE_METHOD
        = "kickstart.locale.jsp.updatekickstart";

    /**
     *
     * {@inheritDoc}
     */
    protected void setupFormValues(RequestContext ctx, DynaActionForm form,
            BaseKickstartCommand cmdIn) {
        KickstartLocaleCommand cmd = (KickstartLocaleCommand) cmdIn;

        ArrayList timezones = cmd.getValidTimezones();
        ctx.getRequest().setAttribute(TIMEZONE_OPTIONS, timezones);

        form.set(TIMEZONE, cmd.getTimezone());
        form.set(USE_UTC, cmd.getKickstartData().isUsingUtc());
    }

    /**
     *
     * {@inheritDoc}
     */
    protected ValidatorError processFormValues(HttpServletRequest request,
            DynaActionForm form,
            BaseKickstartCommand cmd) {

        ValidatorError retval = null;

        KickstartLocaleCommand localeCmd = (KickstartLocaleCommand) cmd;
        cmd = null;

        ArrayList validTimezones = localeCmd.getValidTimezones();
        if (isTimezoneValid(validTimezones, form.getString(TIMEZONE)) == Boolean.TRUE) {
            localeCmd.setTimezone(form.getString(TIMEZONE));
        }
        else {
            retval = new ValidatorError("kickstart.locale." +
                                        "validation.timezone.invalid");
        }

        Boolean useUtc = (Boolean) form.get(USE_UTC);

        if (useUtc == null) {
            useUtc = Boolean.FALSE;
        }

        if (localeCmd.getKickstartData().isUsingUtc().booleanValue() &&
            !useUtc.booleanValue()) {
            localeCmd.doNotUseUtc();
        }
        else if (!localeCmd.getKickstartData().isUsingUtc().booleanValue() &&
                 useUtc.booleanValue()) {
            localeCmd.useUtc();
        }

        return retval;
    }

    /**
     *
     * {@inheritDoc}
     */
    protected String getSuccessKey() {
        return "kickstart.locale.success";
    }

    /**
     *
     * {@inheritDoc}
     */
    protected BaseKickstartCommand getCommand(RequestContext ctx) {
        return new KickstartLocaleCommand(ctx.getRequiredParam(RequestContext.KICKSTART_ID),
                ctx.getCurrentUser());
    }

    /**
     * Is the timezone valid (ie, in the list of valid timezones)
     *
     * return Boolean valid, or not
     */
    protected Boolean isTimezoneValid(ArrayList validTimezones, String timezone) {
        Iterator iter = validTimezones.iterator();

        while (iter.hasNext()) {
            HashMap possible = (HashMap) iter.next();
            if (timezone.equals(possible.get("value"))) {
                return Boolean.TRUE;
            }
        }

        return Boolean.FALSE;
    }
}
