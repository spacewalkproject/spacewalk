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
package com.redhat.rhn.domain.action;

import com.redhat.rhn.common.localization.LocalizationService;

/**
 * ActionFormatter - Class that is responsible for properly formatting the fields
 * on an Action object.  This is so we can localize the output from certain fields
 * as well as produce an HTML version for output on certain fields.
 *
 * @version $Rev$
 */
public class ActionFormatter {

    private Action action;

    /**
     * Create an ActionFormatter with the associated Action.
     * @param actionIn the Action we associate with this Formatter
     */
    public ActionFormatter(Action actionIn) {
        if (actionIn == null) {
            throw new NullPointerException("ActionIn must not be null");
        }
        this.action = actionIn;
    }

    /**
     * Get the Action for this Formatter
     * @return Action associated with this formatter.
     */
    protected Action getAction() {
        return this.action;
    }

    /**
     * Get the first section of the Notes field
     * @return String of the first section
     */
    protected String getNotesHeader() {

        StringBuffer retval = new StringBuffer();

        if (action.getFailedCount().longValue() > 0) {
            retval.append(getActionLink("action.failedlink",
                    action.getFailedCount().longValue()));
        }

        if (action.getSuccessfulCount().longValue() > 0) {
            retval.append(getActionLink("action.completelink",
                    action.getSuccessfulCount().longValue()));

        }
        return retval.toString();

    }

    private String getActionLink(String key, long count) {
        LocalizationService ls = LocalizationService.getInstance();
        //  We may have to append .plural to the key
        //  if the case includes multiple systems
        StringBuffer keybuff = new StringBuffer();
        keybuff.append(key);
        Object[] args = new Object[2];
        args[0] = action.getId().toString();
        args[1] = new Long(count);
        if (count > 1) {
            keybuff.append(".plural");
        }
        return ls.getMessage(keybuff.toString(), args);
    }

    /**
     * No body for the default formatter
     * @return returns an empty string.
     */
    protected String getNotesBody() {
        return "";
    }

    /**
     * Get an HTML version of the notes field
     * @return the HTML String representation of the Notes
     */
    public String getNotes() {
        StringBuffer retval = new StringBuffer();
        retval.append(getNotesHeader());
        retval.append(getNotesBody());
        // The default StringBuffer with nothing in it
        // has the value of "null" so we also want to check
        // for that.
        if (retval.toString().length() == 0 ||
                retval.toString().equals("null")) {
            return LocalizationService.getInstance().getMessage("no notes");
        }
        return retval.toString();

    }

    /**
     * Get the Name of the Action
     * @return String name
     */
    public String getName() {
        if (action.getName() == null) {
            return action.getActionType().getName();
        }
        return action.getName();
    }

    /**
     * Get the Action Type
     * @return String of the ActionType
     */
    public String getActionType() {
        return LocalizationService.getInstance().
            getMessage(action.getActionType().getLabel());
    }

    /**
     * Get the earliest date
     * @return String version of the earliest date
     */
    public String getEarliestDate() {
        return LocalizationService.getInstance().
            formatDate(action.getEarliestAction());
    }

    /**
     * get the login of the scheduler User
     * @return String login of the User
     */
    public String getScheduler() {
        if (action.getSchedulerUser() != null) {
            return action.getSchedulerUser().getLogin();
        }
        return null;
    }

}
