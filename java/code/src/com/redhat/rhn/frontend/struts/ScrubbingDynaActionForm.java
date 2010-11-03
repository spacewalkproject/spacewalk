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

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.DynaActionForm;

import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

/**
 * A DynaActionForm which knows how to scrub its input for malicious content.
 * @version $Rev $
 */
public class ScrubbingDynaActionForm extends DynaActionForm {

    private static final long serialVersionUID = 7679506300113360100L;
    private static final String NO_SCRUB = "no_scrub";
    private static final String NO_PAREN_SCRUB = "no_paren_scrub";

    private static final String[] SPECIAL_PROHIBITED_INPUT = {"<", ">", "\\{", "\\}"};

    /** constructor */
    public ScrubbingDynaActionForm() {
        super();
    }

    /**
     * Tell the form to "scrub thyself"
     */
    public void scrub() {
        List keys = new LinkedList(dynaValues.keySet());

        Set<String> noScrub = new HashSet<String>();
        Set<String> noParenScrub = new HashSet<String>();

        if (dynaValues.containsKey(NO_SCRUB)) {
            for (String item : StringUtils.split(
                    (String)dynaValues.get(NO_SCRUB), ",")) {
                noScrub.add(item.trim());
            }
        }

        if (dynaValues.containsKey(NO_PAREN_SCRUB)) {
            for (String item : StringUtils.split(
                    (String)dynaValues.get(NO_PAREN_SCRUB), ",")) {
                noParenScrub.add(item.trim());
            }
        }

        for (Iterator iter = keys.iterator(); iter.hasNext();) {
            String name = (String) iter.next();
            Object value = dynaValues.get(name);
            if (isScrubbable(name, value, noScrub)) {
                if (noParenScrub.contains(name)) {
                    value = Scrubber.scrub(value, SPECIAL_PROHIBITED_INPUT);
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

    protected boolean isScrubbable(String name, Object value, Set<String> noScrub) {
        if (name.equals(NO_SCRUB) || NO_PAREN_SCRUB.equals(name) ||
                                               noScrub.contains(name)) {
            return false;
        }
        return Scrubber.canScrub(value);
    }
}
