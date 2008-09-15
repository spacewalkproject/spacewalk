/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.rhn.frontend.struts.ScrubbingDynaActionForm;

/**
 * userDetailsForm
 * @version $Rev$
 */
public class UserDetailsForm extends ScrubbingDynaActionForm {
    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = -8243123758725536582L;

    public static final String PASSWORD = "desiredpassword";
    public static final String PASSWORD_CONFIRM = "desiredpasswordConfirm";

    
    /**
     * 
     * {@inheritDoc}
     */
    protected boolean isScrubbable(String name, Object value) {
        //Donot scrub the CERT_TEXT becasue that contains the XML
        //for every other field feel free to scrub.

        if (PASSWORD.equals(name) || PASSWORD_CONFIRM.equals(name)) {
            return false;
        }

        return super.isScrubbable(name, value);
    }
}

