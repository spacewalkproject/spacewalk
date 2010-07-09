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
package com.redhat.rhn.frontend.action.user;

import com.redhat.rhn.common.localization.LocalizationService;

import org.apache.struts.util.LabelValueBean;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * A set of helpers for create user forms.
 * @version $Rev$
 */
public class UserActionHelper {

    private UserActionHelper() {
    }

    /** placeholder string, package protected; so we don't transmit
     * the actual pw but the form doesn't look empty */
    static final String PLACEHOLDER_PASSWORD = "******";
    public static final String DESIRED_PASS = "desiredpassword";
    public static final String DESIRED_PASS_CONFIRM = "desiredpasswordConfirm";

    /**
     * @return List of possible user prefixes
     * get the list of prefixes to populate the prefixes drop-down box.
     * package protected, because nothing outside of actions should need this.*/
    public static List getPrefixes() {
        // SETUP Prefix list
        List preselct = new LinkedList();

        Iterator i = LocalizationService.getInstance().
                            availablePrefixes().iterator();
        while (i.hasNext()) {
            String keyval = (String) i.next();
            StringBuffer msgKey = new StringBuffer("user prefix ");
            msgKey.append(keyval);
            String display = LocalizationService.getInstance().
                    getMessage(msgKey.toString());
            preselct.add(new LabelValueBean(display, keyval));
        }
        return preselct;
    }

    /**
     * get the list of countries to populate the countries drop-down box.
     * package protected, because nothing outside of actions should need this.*/
    static List getCountries() {
        Map cmap = LocalizationService.getInstance().availableCountries();
        Iterator i = cmap.keySet().iterator();
        List countries = new LinkedList();
        while (i.hasNext()) {
            String name = (String) i.next();
            String code = (String) cmap.get(name);
            countries.add(new LabelValueBean(name, code));
        }
        return countries;
    }
}
