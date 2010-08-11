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

import org.apache.struts.action.DynaActionForm;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

/**
 * A DynaActionForm which knows how to scrub its input for malicious content.
 * @version $Rev $
 */
public class ScrubbingDynaActionForm extends DynaActionForm {

    private static final long serialVersionUID = 7679506300113360100L;

    public static final String[] PROHIBITED_INPUT = {"<", ">", "\\(", "\\)", "\\{", "\\}"};

    /** constructor */
    public ScrubbingDynaActionForm() {
        super();
    }

    /**
     * Tell the form to "scrub thyself"
     */
    public void scrub() {
        List keys = new LinkedList(dynaValues.keySet());
        for (Iterator iter = keys.iterator(); iter.hasNext();) {
            String name = (String) iter.next();
            Object value = dynaValues.get(name);
            if (isScrubbable(name, value)) {
                value = Scrubber.scrub(value);
                if (value == null) {
                    dynaValues.remove(name);
                }
                else {
                    dynaValues.put(name, value);
                }
            }
        }
    }

    protected boolean isScrubbable(String name, Object value) {
        return Scrubber.canScrub(value);
    }

}
