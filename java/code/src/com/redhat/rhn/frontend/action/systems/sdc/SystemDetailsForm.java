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
package com.redhat.rhn.frontend.action.systems.sdc;

import com.redhat.rhn.frontend.struts.Scrubber;
import com.redhat.rhn.frontend.struts.ScrubbingDynaActionForm;

import org.apache.commons.lang.ArrayUtils;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

/**
 *
 * SystemDetailsForm
 * @version $Rev$
 */
public class SystemDetailsForm extends ScrubbingDynaActionForm {

    private static final long serialVersionUID = 193849384978349839L;

    public static final String[] SPECIAL_VALUES = {"system_name"};
    public static final String[] SPECIAL_PROHIBITED_INPUT = {"<", ">", "\\{", "\\}"};

    /**
     * Tell the form to "scrub thyself"
     */
    public void scrub() {
        List keys = new LinkedList(dynaValues.keySet());
        for (Iterator iter = keys.iterator(); iter.hasNext();) {
            String name = (String) iter.next();
            Object value = dynaValues.get(name);
            if (isScrubbable(name, value)) {

                if (ArrayUtils.contains(SPECIAL_VALUES, name)) {
                     value = scrubSpecialString((String) value);
                }
                else {
                    value = Scrubber.scrub(value);
                }
                if (value == null) {
                    dynaValues.remove(name);
                }
                else {
                    dynaValues.put(name, value);
                }
            }
        }
    }

    protected Object scrubSpecialString(String value) {
        for (int x = 0; x < SPECIAL_PROHIBITED_INPUT.length; x++) {
            value = value.replaceAll(SPECIAL_PROHIBITED_INPUT[x], "");
        }
        return value;
    }
}
