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
package com.redhat.rhn.frontend.action.systems.virtualization;

import com.redhat.rhn.frontend.struts.ScrubbingDynaActionForm;

/**
 * VirtualGuestsForm
 * @version $Rev$
 */
public class VirtualGuestsForm extends ScrubbingDynaActionForm {

    private String guestAction;
    private String guestSettingToModify = "";
    private String guestSettingValue;

    /**
     * Getter for the dispatch selection.
     * @return Dispatch selection.
     */
    public String getGuestAction() {
        return guestAction;
    }

    /**
     * Setter for dispatch selection.
     * @param dispatchIn Dispatch selection to set.
     */
    public void setGuestAction(String dispatchIn) {
        guestAction = dispatchIn;
    }

    /**
     * Getter for the guestSettingToModify selection.
     * @return Guest setting to be modified.
     */
    public String getGuestSettingToModify() {
        return guestSettingToModify;
    }

    /**
     * Setter for guestSettingToModify selection.
     * @param guestSettingToModifyIn Guest setting to be modified.
     */
    public void setGuestSettingToModify(String guestSettingToModifyIn) {
        guestSettingToModify = guestSettingToModifyIn;
    }

    /**
     * Getter for the guestSettingToModify selection.
     * @return Guest setting to be modified.
     */
    public String getGuestSettingValue() {
        return guestSettingValue;
    }

    /**
     * Setter for guestSettingToModify selection.
     * @param guestSettingValueIn Guest setting to be modified.
     */
    public void setGuestSettingValue(String guestSettingValueIn) {
        guestSettingValue = guestSettingValueIn;
    }

}
