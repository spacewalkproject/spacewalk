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

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;


/**
 * HtmlTag a simple class to render an html tag
 * @version $Rev$
 */

public class HtmlTag extends BaseTag {

    private static final Set<String> VOID_ELEMENTS = new HashSet<String>(Arrays.asList(
        "area", "base", "br", "col", "command", "embed", "hr", "img",
        "input", "keygen", "link", "meta", "param", "source", "track", "wbr"));

    /**
     * Public constructor
     * @param tagIn the name of the tag
     */
    public HtmlTag(String tagIn) {
        super(tagIn, true);
    }

    /**
     * @return Whether the tag name belongs to the list of HTML5
     * void elements.
     * @see http://www.w3.org/TR/html-markup/syntax.html#syntax-elements
     */
    protected boolean isVoidElement() {
        return VOID_ELEMENTS.contains(getTag());
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String render() {
        StringBuilder ret = new StringBuilder();
        if (isVoidElement()) {
            if (hasBody()) {
                throw new IllegalArgumentException("Void html element <" + getTag() +
                                               "> is not allowed to have contents.");
            }

            ret.append(renderOpenTag(true));
        }
        else {
            ret.append(renderOpenTag(false));
            ret.append(renderBody());
            ret.append(renderCloseTag());
        }
        return ret.toString();
    }
}
