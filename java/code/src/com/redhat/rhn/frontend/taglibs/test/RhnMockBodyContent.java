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
package com.redhat.rhn.frontend.taglibs.test;

import com.mockobjects.servlet.MockBodyContent;

/**
 * RhnMockBodyContent
 * Extends MockBodyContent and adds the ability to set
 * the BodyContent to a String.
 * @version $Rev$
 */
public class RhnMockBodyContent extends MockBodyContent {

    private String text;

    /**
     * Constructor - takes a string object to
     * set the text to.
     * @param textIn
     */
    public RhnMockBodyContent(String textIn) {
        setString(textIn);
    }

    /**
     * {@inheritDoc}
     */
    public String getString() {
        return text;
    }

    /**
     * Convienience method to allow you to
     * set the text.
     * @param textIn
     */
    public void setString(String textIn) {
        this.text = textIn;
    }
}
