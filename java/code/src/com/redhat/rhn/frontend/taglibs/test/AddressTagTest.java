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

import com.redhat.rhn.domain.user.Address;
import com.redhat.rhn.frontend.action.user.AddressesAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.AddressTag;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TagTestUtils;

import com.mockobjects.helpers.TagTestHelper;
import com.mockobjects.servlet.MockJspWriter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.tagext.Tag;

/**
 * NavMenuTagTest
 * @version $Rev: 694 $
 */
public class AddressTagTest extends RhnBaseTestCase {

    private ActionHelper sah;

    /**
     * Called once per test method.
     * @throws Exception if an error occurs during setup.
     */
    protected void setUp() throws Exception {
        super.setUp();
        sah = new ActionHelper();
        sah.setUpAction(new AddressesAction());
        sah.getRequest().setRequestURL("foo");
        sah.executeAction();
    }

    /** Test tag output
     */
    public void testTagOutput() throws Exception {

        AddressTag addtg = new AddressTag();
        TagTestHelper tth = TagTestUtils.setupTagTest(addtg, null, sah.getRequest());

        // setup mock objects
        MockJspWriter out = (MockJspWriter)tth.getPageContext().getOut();
        out.setExpectedData(
            getPopulatedReturnValue(sah.getRequest(), sah.getUser().getId()));
        addtg.setType(Address.TYPE_MARKETING);
        addtg.setUser(sah.getUser());
        addtg.setAddress(
            (Address) sah.getRequest().getAttribute(RhnHelper.TARGET_ADDRESS_MARKETING));

        // ok let's test the tag
        tth.assertDoStartTag(Tag.SKIP_BODY);
        out.verify();
    }

    /* Test rendering an empty Address
     */
    public void testEmptyAddress() throws Exception {
        AddressTag addtg = new AddressTag();
        TagTestHelper tth = TagTestUtils.setupTagTest(addtg, null, sah.getRequest());
        // setup mock objects
        MockJspWriter out = (MockJspWriter)tth.getPageContext().getOut();

        out.setExpectedData(getEmptyReturnValue(sah.getRequest(), sah.getUser().getId()));
        // The test User in the super class shouldn't have
        // a SHIPPING address
        addtg.setType(Address.TYPE_MARKETING);
        addtg.setUser(sah.getUser());
        // ok let's test the tag
        tth.assertDoStartTag(Tag.SKIP_BODY);
        out.verify();
    }

    private String getPopulatedReturnValue(HttpServletRequest req, Long uid) {
        return "<div class=\"jumbotron\"><div class=\"container\">" +
            "<h1>Mailing Address</h1>" +
            "<p>444 Castro<br/>#1<br/>Mountain View, CA 94043</p>" +
            "<p>Phone: 650-555-1212<br/>Fax: 650-555-1212</p><p>" +
            "<a class=\"btn btn-success btn-lg\"href=\"/EditAddress.do?" +
            "type=M&amp;uid=" + uid + "\">Edit this address</a></p></div></div>";
    }

    private String getEmptyReturnValue(HttpServletRequest req, Long uid) {
        return "<div class=\"jumbotron\"><div class=\"container\">" +
               "<h1>Mailing Address</h1><div class=\"alert alert-info\">" +
               "Address not filled out</div><p><a class=\"btn btn-success btn-lg\" " +
               "href=\"/EditAddress.do?type=M&amp;uid=" + uid +
               "\">Add this address</a></p></div></div>";
    }

}
