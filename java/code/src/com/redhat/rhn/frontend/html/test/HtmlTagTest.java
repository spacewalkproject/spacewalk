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

package com.redhat.rhn.frontend.html.test;

import com.redhat.rhn.frontend.html.HiddenInputTag;
import com.redhat.rhn.frontend.html.HtmlTag;
import com.redhat.rhn.frontend.html.SubmitImageInputTag;
import com.redhat.rhn.frontend.html.TextInputTag;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * HtmlTagTest
 * @version $Rev$
 */

public class HtmlTagTest extends RhnBaseTestCase {
    public void testTagMaking() throws Exception {
        HtmlTag a = new HtmlTag("a");
        a.addBody("text");
        a.setAttribute("href", "url");
        a.setAttribute("class", "css");
        assertEquals("<a href=\"url\" class=\"css\">text</a>", a.render());

        HtmlTag i = new HtmlTag("img");
        i.setAttribute("src", "url");
        assertEquals("<img src=\"url\" />", i.render());
    }

    public void testChildTags() throws Exception {
        HtmlTag a = new HtmlTag("a");
        a.setAttribute("href", "url");
        HtmlTag img = new HtmlTag("img");
        img.setAttribute("src", "foo.gif");
        a.addBody(img);

        assertEquals("<a href=\"url\"><img src=\"foo.gif\" /></a>", a.render());
    }

    public void testChildTagAndBody() throws Exception {
        HtmlTag a = new HtmlTag("a");
        a.setAttribute("href", "url");
        a.addBody("Preferences");
        HtmlTag img = new HtmlTag("img");
        img.setAttribute("src", "foo.gif");
        a.addBody(img);

        assertEquals("<a href=\"url\">Preferences<img src=\"foo.gif\" /></a>", a.render());
    }

    public void testHasBody() {
        HtmlTag a = new HtmlTag("a");
        assertFalse(a.hasBody());
    }

    public void testTextInputTag() {
        TextInputTag i = new TextInputTag();
        i.setName("testing");
        i.setSize(10);
        i.setValue("something");
        assertEquals(
           "<input type=\"text\" name=\"testing\" size=\"10\" value=\"something\" />",
           i.render());

    }

    public void testHiddenInputTag() {
        HiddenInputTag i = new HiddenInputTag();
        i.setName("testing");
        i.setValue("something");
        assertEquals("<input type=\"hidden\" name=\"testing\" value=\"something\" />",
            i.render());
    }

    public void testSubmitImageInputTag() {
        SubmitImageInputTag i = new SubmitImageInputTag();
        i.setName("testing");
        i.setAlt("alt text");
        i.setSrc("/rhn.gif");
        assertEquals(
           "<input type=\"image\" name=\"testing\" alt=\"alt text\" src=\"/rhn.gif\" />",
           i.render());
    }

    public void testRemoveAttribute() {
        HtmlTag td = new HtmlTag("td");
        td.setAttribute("class", "sidebar");
        assertEquals("<td class=\"sidebar\" />", td.render());
        td.removeAttribute("class");
        assertEquals("<td />", td.render());
    }

}


