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
 * SubmitImageInputTag a simple class to render a text input tag
 *
 * <input alt="txt" name="test" src="/img/button-go.gif" type="image" />
 *
 * @version $Rev$
 */

public class SubmitImageInputTag extends InputTag {

    /**
     * Public constructor for SubmitImageInputTag html tag
     */
    public SubmitImageInputTag() {
        setAttribute("type", "image");
    }

    /**
     * set the alt text to be used if there is no image
     * @param alt text to display
     */
    public void setAlt(String alt) {
        setAttribute("alt", alt);
    }

    /**
     * set the path to the image
     * @param src url to the image for the button
     */
    public void setSrc(String src) {
        setAttribute("src", src);
    }
}
