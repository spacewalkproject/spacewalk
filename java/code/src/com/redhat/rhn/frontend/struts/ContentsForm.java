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
 * ContentsForm
 * @version $Rev$
 */
public class ContentsForm extends ScrubbingDynaActionForm {
    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = -9000654809510147444L;
    private static final String CONTENTS = "contents";

    /**
     *
     * {@inheritDoc}
     */
    protected boolean isScrubbable(String name, Object value) {
        //Donot scrub the Contents because that contains the other characters
        //for every other field feel free to scrub.
        if (name.toLowerCase().contains(CONTENTS)) {
            return false;
        }
        return super.isScrubbable(name, value);
    }
}
