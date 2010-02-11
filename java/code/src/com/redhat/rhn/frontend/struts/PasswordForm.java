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

package com.redhat.rhn.frontend.struts;


/**
 * This class basically scrubs all the properties
 * in the dynaform except those properties containing the word Password.
 * @author paji
 * @version $Rev $
 */
public class PasswordForm extends ScrubbingDynaActionForm {
    private static final long serialVersionUID = -7565323006365800525L;
    private static final String PASSWORD = "password";

    /**
     *
     * {@inheritDoc}
     */
    protected boolean isScrubbable(String name, Object value) {
        //Donot scrub the Password because that contains the other characters
        //for every other field feel free to scrub.
        if (name.toLowerCase().contains(PASSWORD)) {
            return false;
        }
        return super.isScrubbable(name, value);
    }
}
