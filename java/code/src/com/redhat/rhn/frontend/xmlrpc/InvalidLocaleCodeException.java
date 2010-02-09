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
package com.redhat.rhn.frontend.xmlrpc;

import com.redhat.rhn.FaultException;

/**
 * InvalidLocaleCodeException thrown when an invalid locale is passed in as
 * an argument.
 * @version $Rev$
 */
public class InvalidLocaleCodeException extends FaultException {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 2976246208163619309L;

    /**
     * constructor
     * @param locale invalid locale
     */
    public InvalidLocaleCodeException(String locale) {
        super(2500, "invalidLocaleId", locale + " is an invalid locale id");
    }
    
    /**
     * constructor
     * @param locale invalid locale
     * @param cause exception being wrapped
     */
    public InvalidLocaleCodeException(String locale, Throwable cause) {
        super(2500, "invalidLocaleId", locale +
                " is an invalid locale id", cause);
    }
}
