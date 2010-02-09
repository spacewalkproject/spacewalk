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

package com.redhat.rhn.frontend.html;


/**
 * InputTag a simple class to render a an input tag
 *
 * @version $Rev$
 */

public class InputTag extends HtmlTag {

    /**
     * Public constructor for InputTag html tag
     */
    public InputTag() {
        super("input");
    }

    /**
     * set the name of the input
     * @param name name of the input 
     */
    public void setName(String name) {
        setAttribute("name", name);
    }

    /**
     * set the size of the input
     * @param size of the input 
     */
    public void setSize(int size) {
        setAttribute("size",  Integer.toString(size));
    }

    /**
     * set the value of the input
     * @param value of the input 
     */
    public void setValue(String value) {
        setAttribute("value", value);
    }
}
